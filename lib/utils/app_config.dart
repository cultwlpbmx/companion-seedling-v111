import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// 从 .env 文件读取 API Key
  static String get openRouterApiKey {
    return dotenv.env['OPENROUTER_API_KEY'] ?? '';
  }

  static String get stepFunApiKey {
    return dotenv.env['STEPFUN_API_KEY'] ?? '';
  }

  static String get aliYunApiKey {
    return dotenv.env['ALIYUN_API_KEY'] ?? '';
  }

  static String get ollamaApiUrl {
    return dotenv.env['OLLAMA_API_URL'] ?? 'http://localhost:11434';
  }

  static String get ollamaModel {
    return dotenv.env['OLLAMA_MODEL'] ?? 'seedling-counselor';
  }

  static String get provider {
    // 检查是否明确指定了 provider
    final specifiedProvider = dotenv.env['PROVIDER'];
    if (specifiedProvider != null && specifiedProvider.isNotEmpty) {
      return specifiedProvider;
    }
    
    // 否则按优先级检查（在线 API 优先）
    if (aliYunApiKey.isNotEmpty) return 'aliyun';  // 阿里云通义千问（推荐）
    if (stepFunApiKey.isNotEmpty) return 'stepfun'; // 阶跃星辰
    if (openRouterApiKey.isNotEmpty) return 'openrouter'; // OpenRouter
    return 'aliyun'; // 默认使用阿里云（在线 API，稳定可靠）
  }

  static String get aiApiKey {
    switch (provider) {
      case 'ollama': return ''; // Ollama 不需要 API Key
      case 'aliyun': return aliYunApiKey;
      case 'stepfun': return stepFunApiKey;
      case 'openrouter': return openRouterApiKey;
      default: return '';
    }
  }

  static String get model {
    switch (provider) {
      case 'ollama': return ollamaModel;
      case 'aliyun': return 'qwen-plus';
      case 'stepfun': return 'step-3.5-flash';
      case 'openrouter': return 'mistralai/mixtral-8x7b-instruct';
      default: return 'seedling-counselor';
    }
  }
}
