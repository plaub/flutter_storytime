import 'dart:convert';

class RiddleEvent {
  final bool isRiddle2Event;
  final String riddleId;
  final String category;
  final String action;
  final int blockId;
  final String blockType;
  final String blockTypeGroup;
  final String blockTitle;
  final String blockDescription;
  final BlockContent? blockContent;
  final BlockOptions? blockOptions;
  final int playTimeInMilliseconds;
  final Map<String, dynamic> riddleDataLayer;
  final String? name;
  final List<dynamic> trackNetworks;
  final int? answerScore;
  final bool? answerIsCorrect;
  final int? answerTotalScore;
  final String? answer;
  final int? resultScore;
  final int? resultTotalScore;
  final int? resultScorePercentage;
  final List<FormAnswer>? formAnswers;

  RiddleEvent({
    required this.isRiddle2Event,
    required this.riddleId,
    required this.category,
    required this.action,
    required this.blockId,
    required this.blockType,
    required this.blockTypeGroup,
    required this.blockTitle,
    required this.blockDescription,
    required this.blockContent,
    required this.blockOptions,
    required this.playTimeInMilliseconds,
    required this.riddleDataLayer,
    this.name,
    required this.trackNetworks,
    this.answerScore,
    this.answerIsCorrect,
    this.answerTotalScore,
    this.answer,
    this.resultScore,
    this.resultTotalScore,
    this.resultScorePercentage,
    this.formAnswers,
  });

  factory RiddleEvent.fromJson(Map<String, dynamic> json) {
    return RiddleEvent(
      isRiddle2Event: json['isRiddle2Event'],
      riddleId: json['riddleId'],
      category: json['category'],
      action: json['action'],
      blockId: json['blockId'],
      blockType: json['blockType'],
      blockTypeGroup: json['blockTypeGroup'],
      blockTitle: json['blockTitle'],
      blockDescription: json['blockDescription'],
      blockContent: BlockContent.fromJson(json['blockContent']),
      blockOptions: BlockOptions.fromJson(json['blockOptions']),
      playTimeInMilliseconds: json['playTimeInMilliseconds'],
      riddleDataLayer: json['riddleDataLayer'],
      name: json['name'],
      trackNetworks: json['trackNetworks'],
      answerScore: json['answerScore'],
      answerIsCorrect: json['answerIsCorrect'],
      answerTotalScore: json['answerTotalScore'],
      answer: json['answer'],
      resultScore: json['resultScore'],
      resultTotalScore: json['resultTotalScore'],
      resultScorePercentage: json['resultScorePercentage'],
      formAnswers: json['formAnswers'] != null
          ? (json['formAnswers'] as List)
              .map((answer) => FormAnswer.fromJson(answer))
              .toList()
          : null,
    );
  }
}

class BlockContent {
  final String? description;
  final dynamic media;
  final String? title;
  final List<QuizItem>? quizItems;
  final FormConfig? formConfig;
  final List<Block>? blocks;

  BlockContent({
    required this.description,
    this.media,
    required this.title,
    this.quizItems,
    this.formConfig,
    this.blocks,
  });

  factory BlockContent.fromJson(Map<String, dynamic> json) {
    return BlockContent(
      description: json['description'],
      media: json['media'],
      title: json['title'],
      quizItems: json['quizItems'] != null
          ? (json['quizItems'] as List)
              .map((item) => QuizItem.fromJson(item))
              .toList()
          : null,
      formConfig: json['formConfig'] != null
          ? FormConfig.fromJson(json['formConfig'])
          : null,
      blocks: json['blocks'] != null
          ? (json['blocks'] as List)
              .map((item) => Block.fromJson(item))
              .toList()
          : null,
    );
  }
}

class QuizItem {
  final String? description;
  final int? id;
  final dynamic? media;
  final String? title;

  QuizItem({
    required this.description,
    required this.id,
    this.media,
    required this.title,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      description: json['description'],
      id: json['id'],
      media: json['media'],
      title: json['title'],
    );
  }
}

class FormConfig {
  final String? description;
  final String? label;
  final dynamic? placeholder;
  final String? prefilledText;
  final Captcha? captcha;

  FormConfig({
    required this.description,
    required this.label,
    this.placeholder,
    required this.prefilledText,
    this.captcha,
  });

  factory FormConfig.fromJson(Map<String, dynamic> json) {
    return FormConfig(
      description: json['description'],
      label: json['label'],
      placeholder: json['placeholder'],
      prefilledText: json['prefilledText'],
      captcha:
          json['captcha'] != null ? Captcha.fromJson(json['captcha']) : null,
    );
  }
}

class Captcha {
  final String? description;
  final String? key;
  final String? label;
  final String? secret;
  final String? type;

  Captcha({
    this.description,
    this.key,
    this.label,
    this.secret,
    required this.type,
  });

  factory Captcha.fromJson(Map<String, dynamic> json) {
    return Captcha(
      description: json['description'],
      key: json['key'],
      label: json['label'],
      secret: json['secret'],
      type: json['type'],
    );
  }
}

class Block {
  final dynamic? value;
  final int? height;
  final int? id;
  final String? type;
  final int? width;
  final int? x;
  final int? y;
  final int? zIndex;

  Block({
    required this.value,
    required this.height,
    required this.id,
    required this.type,
    required this.width,
    required this.x,
    required this.y,
    required this.zIndex,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      value: json['value'],
      height: json['height'],
      id: json['id'],
      type: json['type'],
      width: json['width'],
      x: json['x'],
      y: json['y'],
      zIndex: json['zIndex'],
    );
  }
}

class BlockOptions {
  final bool? isMediaEnabled;
  final String? mediaOrientation;
  final bool? isCorrectAnswerBtnVisible;
  final AnswerExplanationOptions? answerExplanationOptions;
  final LayoutOptions? layoutOptions;
  final QuizAnswerOptions? quizAnswerOptions;
  final FormOptions? formOptions;

  BlockOptions({
    required this.isMediaEnabled,
    required this.mediaOrientation,
    required this.isCorrectAnswerBtnVisible,
    this.answerExplanationOptions,
    this.layoutOptions,
    this.quizAnswerOptions,
    this.formOptions,
  });

  factory BlockOptions.fromJson(Map<String, dynamic> json) {
    return BlockOptions(
      isMediaEnabled: json['isMediaEnabled'],
      mediaOrientation: json['mediaOrientation'],
      isCorrectAnswerBtnVisible: json['isCorrectAnswerBtnVisible'],
      answerExplanationOptions: json['answerExplanationOptions'] != null
          ? AnswerExplanationOptions.fromJson(json['answerExplanationOptions'])
          : null,
      layoutOptions: json['layoutOptions'] != null
          ? LayoutOptions.fromJson(json['layoutOptions'])
          : null,
      quizAnswerOptions: json['quizAnswerOptions'] != null
          ? QuizAnswerOptions.fromJson(json['quizAnswerOptions'])
          : null,
      formOptions: json['formOptions'] != null
          ? FormOptions.fromJson(json['formOptions'])
          : null,
    );
  }
}

class AnswerExplanationOptions {
  final bool? isEnabled;
  final bool? isMediaEnabled;
  final String? type;
  final String? mediaOrientation;
  final String? position;

  AnswerExplanationOptions({
    required this.isEnabled,
    required this.isMediaEnabled,
    required this.type,
    required this.mediaOrientation,
    required this.position,
  });

  factory AnswerExplanationOptions.fromJson(Map<String, dynamic> json) {
    return AnswerExplanationOptions(
      isEnabled: json['isEnabled'],
      isMediaEnabled: json['isMediaEnabled'],
      type: json['type'],
      mediaOrientation: json['mediaOrientation'],
      position: json['position'],
    );
  }
}

class LayoutOptions {
  final String? layoutType;
  final bool? canWrapItems;
  final bool? isHeightFlexible;

  LayoutOptions({
    required this.layoutType,
    required this.canWrapItems,
    required this.isHeightFlexible,
  });

  factory LayoutOptions.fromJson(Map<String, dynamic> json) {
    return LayoutOptions(
      layoutType: json['layoutType'],
      canWrapItems: json['canWrapItems'],
      isHeightFlexible: json['isHeightFlexible'],
    );
  }
}

class QuizAnswerOptions {
  final bool? isDescriptionVisible;
  final bool? isMediaVisible;
  final bool? isRightOrWrong;
  final String? mediaOrientation;
  final List<dynamic>? scoring;

  QuizAnswerOptions({
    required this.isDescriptionVisible,
    required this.isMediaVisible,
    required this.isRightOrWrong,
    required this.mediaOrientation,
    required this.scoring,
  });

  factory QuizAnswerOptions.fromJson(Map<String, dynamic> json) {
    return QuizAnswerOptions(
      isDescriptionVisible: json['isDescriptionVisible'],
      isMediaVisible: json['isMediaVisible'],
      isRightOrWrong: json['isRightOrWrong'],
      mediaOrientation: json['mediaOrientation'],
      scoring: json['scoring'],
    );
  }
}

class FormOptions {
  final String? fieldId;
  final int? id;
  final bool? isDescriptionEnabled;
  final bool? isPrefilledTextEnabled;
  final bool? isRequired;
  final int? maxLength;
  final dynamic? requiredMessage;
  final bool? isAdvancedValidationEnabled;
  final bool? isHidden;

  FormOptions({
    required this.fieldId,
    required this.id,
    required this.isDescriptionEnabled,
    required this.isPrefilledTextEnabled,
    required this.isRequired,
    required this.maxLength,
    this.requiredMessage,
    required this.isAdvancedValidationEnabled,
    required this.isHidden,
  });

  factory FormOptions.fromJson(Map<String, dynamic> json) {
    return FormOptions(
      fieldId: json['fieldId'],
      id: json['id'],
      isDescriptionEnabled: json['isDescriptionEnabled'],
      isPrefilledTextEnabled: json['isPrefilledTextEnabled'],
      isRequired: json['isRequired'],
      maxLength: json['maxLength'],
      requiredMessage: json['requiredMessage'],
      isAdvancedValidationEnabled: json['isAdvancedValidationEnabled'],
      isHidden: json['isHidden'],
    );
  }
}

class FormAnswer {
  final String? data;
  final String? label;
  final String? status;
  final int? blockId;
  final String? blockType;
  final String? blockTypeGroup;
  final String? blockTitle;
  final String? blockDescription;
  final BlockContent? blockContent;
  final BlockOptions? blockOptions;

  FormAnswer({
    required this.data,
    required this.label,
    required this.status,
    required this.blockId,
    required this.blockType,
    required this.blockTypeGroup,
    required this.blockTitle,
    required this.blockDescription,
    required this.blockContent,
    required this.blockOptions,
  });

  factory FormAnswer.fromJson(Map<String, dynamic> json) {
    return FormAnswer(
      data: json['data'],
      label: json['label'],
      status: json['status'],
      blockId: json['blockId'],
      blockType: json['blockType'],
      blockTypeGroup: json['blockTypeGroup'],
      blockTitle: json['blockTitle'],
      blockDescription: json['blockDescription'],
      blockContent: BlockContent.fromJson(json['blockContent']),
      blockOptions: BlockOptions.fromJson(json['blockOptions']),
    );
  }
}
