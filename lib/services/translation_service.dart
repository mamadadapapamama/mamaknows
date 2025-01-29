import 'dart:io';
import 'dart:convert';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis/translate/v3.dart' as translate;
import 'package:googleapis_auth/auth_io.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../config/api_config.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // late 제거하고 nullable로 변경
  vision.VisionApi? _visionApi;
  translate.TranslateApi? _translateApi;
  final FlutterTts _tts = FlutterTts();

  // 초기화 메서드
  Future<void> initialize() async {
    if (_visionApi != null && _translateApi != null) {
      return;
    }

    try {
      // OAuth2 인증 정보 설정
      final credentials = ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": ApiConfig.projectId,
        "private_key_id": ApiConfig.privateKeyId,
        "private_key": ApiConfig.privateKey,
        "client_email": ApiConfig.clientEmail,
        "client_id": ApiConfig.clientId,
      });

      final scopes = [
        'https://www.googleapis.com/auth/cloud-vision',
        'https://www.googleapis.com/auth/cloud-translation',
      ];

      final client = await clientViaServiceAccount(credentials, scopes);
      _visionApi = vision.VisionApi(client);
      _translateApi = translate.TranslateApi(client);
      await _tts.setLanguage('zh-CN');
    } catch (e) {
      print('Translation Service 초기화 실패: $e');
      rethrow;
    }
  }

  // 텍스트 추출 메서드
  Future<String> extractText(String imagePath) async {
    await initialize();
    if (_visionApi == null) {
      throw Exception('Vision API가 초기화되지 않았습니다.');
    }

    try {
      final bytes = await File(imagePath).readAsBytes();
      final request = vision.BatchAnnotateImagesRequest(requests: [
        vision.AnnotateImageRequest(
          image: vision.Image(
            content: base64Encode(bytes),
          ),
          features: [
            vision.Feature(
              maxResults: 1,
              type: 'TEXT_DETECTION',
            ),
          ],
        ),
      ]);

      final response = await _visionApi!.images.annotate(request);
      return response.responses?.first.textAnnotations?.first.description ?? '';
    } catch (e) {
      print('텍스트 추출 실패: $e');
      rethrow;
    }
  }

  // 번역 메서드
  Future<String> translateText(String text, {String from = 'zh', String to = 'ko'}) async {
    await initialize();
    if (_translateApi == null) {
      throw Exception('Translation API가 초기화되지 않았습니다.');
    }

    try {
      final parent = 'projects/${ApiConfig.projectId}';  // 프로젝트 ID 필요
      final request = translate.TranslateTextRequest(
        contents: [text],
        sourceLanguageCode: from,
        targetLanguageCode: to,
      );

      final response = await _translateApi!.projects.translateText(request, parent);
      if (response.translations != null && response.translations!.isNotEmpty) {
        return response.translations!.first.translatedText ?? '';
      } else {
        throw Exception('No translations found');
      }
    } catch (e) {
      print('번역 실패: $e');
      rethrow; // Re-throw the exception for further handling
    }
  }

  // 병음 생성
  String getPinyin(String chineseText) {
    return PinyinHelper.getPinyin(chineseText);
  }

  // TTS
  Future<void> speak(String text, {String language = 'zh-CN'}) async {
    await initialize();
    try {
      await _tts.setLanguage(language);
      await _tts.speak(text);
    } catch (e) {
      print('TTS 실패: $e');
      rethrow;
    }
  }

  // 전체 처리
  Future<Map<String, String>> processImage(String imagePath) async {
    await initialize();
    if (_visionApi == null || _translateApi == null) {
      throw Exception('Vision API 또는 Translation API가 초기화되지 않았습니다.');
    }

    try {
      final extractedText = await extractText(imagePath);
      final translatedText = await translateText(extractedText);
      final pinyin = getPinyin(extractedText);

      return {
        'originalText': extractedText,
        'translatedText': translatedText,
        'pinyin': pinyin,
      };
    } catch (e) {
      print('이미지 처리 실패: $e');
      rethrow;
    }
  }
}