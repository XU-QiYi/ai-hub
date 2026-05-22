import 'package:flutter/material.dart';
import '../models/ai_service.dart';

final List<AiService> aiServices = [
  AiService(
    name: 'Kimi',
    url: 'https://kimi.moonshot.cn',
    description: '擅长长文本处理',
    icon: Icons.auto_awesome,
    packageName: 'com.moonshot.kimichat',
  ),
  AiService(
    name: '豆包',
    url: 'https://www.doubao.com',
    description: '字节跳动旗下全能助手',
    icon: Icons.chat_bubble_outline,
    packageName: 'com.larus.nova',
  ),
  AiService(
    name: 'DeepSeek',
    url: 'https://chat.deepseek.com',
    description: '推理能力出色',
    icon: Icons.explore_outlined,
    packageName: 'com.deepseek.chat',
  ),
  AiService(
    name: '千问',
    url: 'https://tongyi.aliyun.com',
    description: '阿里通义系列核心产品',
    icon: Icons.menu_book_outlined,
    packageName: 'com.aliyun.tongyi',
  ),
  AiService(
    name: '文心一言',
    url: 'https://yiyan.baidu.com',
    description: '百度文心大模型产品',
    icon: Icons.article_outlined,
    packageName: 'com.baidu.newapp',
  ),
  AiService(
    name: '智谱清言',
    url: 'https://chatglm.cn',
    description: '清华 GLM 系列产品',
    icon: Icons.psychology_outlined,
    packageName: 'com.zhipuai.qingyan',
  ),
  AiService(
    name: '讯飞星火',
    url: 'https://xinghuo.xfyun.cn',
    description: '科大讯飞语音与语言模型',
    icon: Icons.graphic_eq_outlined,
    packageName: null,
  ),
  AiService(
    name: '腾讯元宝',
    url: 'https://yuanbao.tencent.com',
    description: '腾讯混元对话产品',
    icon: Icons.account_balance_wallet_outlined,
    packageName: 'com.tencent.hunyuan.app.chat',
  ),
  AiService(
    name: 'Coze',
    url: 'https://www.coze.cn',
    description: '字节跳动 AI Bot 平台',
    icon: Icons.extension_outlined,
    packageName: null,
  ),
  AiService(
    name: '腾讯混元',
    url: 'https://hunyuan.tencent.com',
    description: '腾讯自研大模型',
    icon: Icons.science_outlined,
    packageName: null,
  ),
  AiService(
    name: 'MiMo',
    url: 'https://aistudio.xiaomimimo.com/#/c',
    description: '小米自研大模型',
    icon: Icons.smart_toy_outlined,
    packageName: null,
  ),
  AiService(
    name: 'Minimax',
    url: 'https://chat.minimax.io',
    description: 'MiniMax 对话产品',
    icon: Icons.speed_outlined,
    packageName: null,
  ),
];
