// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HymnsTable extends Hymns with TableInfo<$HymnsTable, Hymn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HymnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hymnalTypeMeta = const VerificationMeta(
    'hymnalType',
  );
  @override
  late final GeneratedColumn<String> hymnalType = GeneratedColumn<String>(
    'hymnal_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    number,
    title,
    content,
    hymnalType,
    isFavorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hymns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Hymn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('hymnal_type')) {
      context.handle(
        _hymnalTypeMeta,
        hymnalType.isAcceptableOrUnknown(data['hymnal_type']!, _hymnalTypeMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number, hymnalType};
  @override
  Hymn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hymn(
      number:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}number'],
          )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      hymnalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hymnal_type'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      ),
    );
  }

  @override
  $HymnsTable createAlias(String alias) {
    return $HymnsTable(attachedDatabase, alias);
  }
}

class Hymn extends DataClass implements Insertable<Hymn> {
  final int number;
  final String? title;
  final String? content;
  final String? hymnalType;
  final bool? isFavorite;
  const Hymn({
    required this.number,
    this.title,
    this.content,
    this.hymnalType,
    this.isFavorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || hymnalType != null) {
      map['hymnal_type'] = Variable<String>(hymnalType);
    }
    if (!nullToAbsent || isFavorite != null) {
      map['is_favorite'] = Variable<bool>(isFavorite);
    }
    return map;
  }

  HymnsCompanion toCompanion(bool nullToAbsent) {
    return HymnsCompanion(
      number: Value(number),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      content:
          content == null && nullToAbsent
              ? const Value.absent()
              : Value(content),
      hymnalType:
          hymnalType == null && nullToAbsent
              ? const Value.absent()
              : Value(hymnalType),
      isFavorite:
          isFavorite == null && nullToAbsent
              ? const Value.absent()
              : Value(isFavorite),
    );
  }

  factory Hymn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hymn(
      number: serializer.fromJson<int>(json['number']),
      title: serializer.fromJson<String?>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      hymnalType: serializer.fromJson<String?>(json['hymnalType']),
      isFavorite: serializer.fromJson<bool?>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'title': serializer.toJson<String?>(title),
      'content': serializer.toJson<String?>(content),
      'hymnalType': serializer.toJson<String?>(hymnalType),
      'isFavorite': serializer.toJson<bool?>(isFavorite),
    };
  }

  Hymn copyWith({
    int? number,
    Value<String?> title = const Value.absent(),
    Value<String?> content = const Value.absent(),
    Value<String?> hymnalType = const Value.absent(),
    Value<bool?> isFavorite = const Value.absent(),
  }) => Hymn(
    number: number ?? this.number,
    title: title.present ? title.value : this.title,
    content: content.present ? content.value : this.content,
    hymnalType: hymnalType.present ? hymnalType.value : this.hymnalType,
    isFavorite: isFavorite.present ? isFavorite.value : this.isFavorite,
  );
  Hymn copyWithCompanion(HymnsCompanion data) {
    return Hymn(
      number: data.number.present ? data.number.value : this.number,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      hymnalType:
          data.hymnalType.present ? data.hymnalType.value : this.hymnalType,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hymn(')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('hymnalType: $hymnalType, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(number, title, content, hymnalType, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hymn &&
          other.number == this.number &&
          other.title == this.title &&
          other.content == this.content &&
          other.hymnalType == this.hymnalType &&
          other.isFavorite == this.isFavorite);
}

class HymnsCompanion extends UpdateCompanion<Hymn> {
  final Value<int> number;
  final Value<String?> title;
  final Value<String?> content;
  final Value<String?> hymnalType;
  final Value<bool?> isFavorite;
  final Value<int> rowid;
  const HymnsCompanion({
    this.number = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.hymnalType = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HymnsCompanion.insert({
    required int number,
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.hymnalType = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : number = Value(number);
  static Insertable<Hymn> custom({
    Expression<int>? number,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? hymnalType,
    Expression<bool>? isFavorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (hymnalType != null) 'hymnal_type': hymnalType,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HymnsCompanion copyWith({
    Value<int>? number,
    Value<String?>? title,
    Value<String?>? content,
    Value<String?>? hymnalType,
    Value<bool?>? isFavorite,
    Value<int>? rowid,
  }) {
    return HymnsCompanion(
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
      hymnalType: hymnalType ?? this.hymnalType,
      isFavorite: isFavorite ?? this.isFavorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (hymnalType.present) {
      map['hymnal_type'] = Variable<String>(hymnalType.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HymnsCompanion(')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('hymnalType: $hymnalType, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResponsiveReadingsTable extends ResponsiveReadings
    with TableInfo<$ResponsiveReadingsTable, ResponsiveReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResponsiveReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [number, title, content, isFavorite];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'responsive_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResponsiveReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  ResponsiveReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResponsiveReading(
      number:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}number'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      ),
    );
  }

  @override
  $ResponsiveReadingsTable createAlias(String alias) {
    return $ResponsiveReadingsTable(attachedDatabase, alias);
  }
}

class ResponsiveReading extends DataClass
    implements Insertable<ResponsiveReading> {
  final int number;
  final String title;
  final String content;
  final bool? isFavorite;
  const ResponsiveReading({
    required this.number,
    required this.title,
    required this.content,
    this.isFavorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || isFavorite != null) {
      map['is_favorite'] = Variable<bool>(isFavorite);
    }
    return map;
  }

  ResponsiveReadingsCompanion toCompanion(bool nullToAbsent) {
    return ResponsiveReadingsCompanion(
      number: Value(number),
      title: Value(title),
      content: Value(content),
      isFavorite:
          isFavorite == null && nullToAbsent
              ? const Value.absent()
              : Value(isFavorite),
    );
  }

  factory ResponsiveReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResponsiveReading(
      number: serializer.fromJson<int>(json['number']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      isFavorite: serializer.fromJson<bool?>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'isFavorite': serializer.toJson<bool?>(isFavorite),
    };
  }

  ResponsiveReading copyWith({
    int? number,
    String? title,
    String? content,
    Value<bool?> isFavorite = const Value.absent(),
  }) => ResponsiveReading(
    number: number ?? this.number,
    title: title ?? this.title,
    content: content ?? this.content,
    isFavorite: isFavorite.present ? isFavorite.value : this.isFavorite,
  );
  ResponsiveReading copyWithCompanion(ResponsiveReadingsCompanion data) {
    return ResponsiveReading(
      number: data.number.present ? data.number.value : this.number,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResponsiveReading(')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(number, title, content, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResponsiveReading &&
          other.number == this.number &&
          other.title == this.title &&
          other.content == this.content &&
          other.isFavorite == this.isFavorite);
}

class ResponsiveReadingsCompanion extends UpdateCompanion<ResponsiveReading> {
  final Value<int> number;
  final Value<String> title;
  final Value<String> content;
  final Value<bool?> isFavorite;
  const ResponsiveReadingsCompanion({
    this.number = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  ResponsiveReadingsCompanion.insert({
    this.number = const Value.absent(),
    required String title,
    required String content,
    this.isFavorite = const Value.absent(),
  }) : title = Value(title),
       content = Value(content);
  static Insertable<ResponsiveReading> custom({
    Expression<int>? number,
    Expression<String>? title,
    Expression<String>? content,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  ResponsiveReadingsCompanion copyWith({
    Value<int>? number,
    Value<String>? title,
    Value<String>? content,
    Value<bool?>? isFavorite,
  }) {
    return ResponsiveReadingsCompanion(
      number: number ?? this.number,
      title: title ?? this.title,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResponsiveReadingsCompanion(')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

class $ThematicListsTable extends ThematicLists
    with TableInfo<$ThematicListsTable, ThematicList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThematicListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _thematicMeta = const VerificationMeta(
    'thematic',
  );
  @override
  late final GeneratedColumn<String> thematic = GeneratedColumn<String>(
    'thematic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hymnalTypeMeta = const VerificationMeta(
    'hymnalType',
  );
  @override
  late final GeneratedColumn<String> hymnalType = GeneratedColumn<String>(
    'hymnal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, thematic, hymnalType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thematic_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThematicList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('thematic')) {
      context.handle(
        _thematicMeta,
        thematic.isAcceptableOrUnknown(data['thematic']!, _thematicMeta),
      );
    } else if (isInserting) {
      context.missing(_thematicMeta);
    }
    if (data.containsKey('hymnal_type')) {
      context.handle(
        _hymnalTypeMeta,
        hymnalType.isAcceptableOrUnknown(data['hymnal_type']!, _hymnalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_hymnalTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThematicList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThematicList(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      thematic:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}thematic'],
          )!,
      hymnalType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}hymnal_type'],
          )!,
    );
  }

  @override
  $ThematicListsTable createAlias(String alias) {
    return $ThematicListsTable(attachedDatabase, alias);
  }
}

class ThematicList extends DataClass implements Insertable<ThematicList> {
  final int id;
  final String thematic;
  final String hymnalType;
  const ThematicList({
    required this.id,
    required this.thematic,
    required this.hymnalType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['thematic'] = Variable<String>(thematic);
    map['hymnal_type'] = Variable<String>(hymnalType);
    return map;
  }

  ThematicListsCompanion toCompanion(bool nullToAbsent) {
    return ThematicListsCompanion(
      id: Value(id),
      thematic: Value(thematic),
      hymnalType: Value(hymnalType),
    );
  }

  factory ThematicList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThematicList(
      id: serializer.fromJson<int>(json['id']),
      thematic: serializer.fromJson<String>(json['thematic']),
      hymnalType: serializer.fromJson<String>(json['hymnalType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'thematic': serializer.toJson<String>(thematic),
      'hymnalType': serializer.toJson<String>(hymnalType),
    };
  }

  ThematicList copyWith({int? id, String? thematic, String? hymnalType}) =>
      ThematicList(
        id: id ?? this.id,
        thematic: thematic ?? this.thematic,
        hymnalType: hymnalType ?? this.hymnalType,
      );
  ThematicList copyWithCompanion(ThematicListsCompanion data) {
    return ThematicList(
      id: data.id.present ? data.id.value : this.id,
      thematic: data.thematic.present ? data.thematic.value : this.thematic,
      hymnalType:
          data.hymnalType.present ? data.hymnalType.value : this.hymnalType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThematicList(')
          ..write('id: $id, ')
          ..write('thematic: $thematic, ')
          ..write('hymnalType: $hymnalType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, thematic, hymnalType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThematicList &&
          other.id == this.id &&
          other.thematic == this.thematic &&
          other.hymnalType == this.hymnalType);
}

class ThematicListsCompanion extends UpdateCompanion<ThematicList> {
  final Value<int> id;
  final Value<String> thematic;
  final Value<String> hymnalType;
  const ThematicListsCompanion({
    this.id = const Value.absent(),
    this.thematic = const Value.absent(),
    this.hymnalType = const Value.absent(),
  });
  ThematicListsCompanion.insert({
    this.id = const Value.absent(),
    required String thematic,
    required String hymnalType,
  }) : thematic = Value(thematic),
       hymnalType = Value(hymnalType);
  static Insertable<ThematicList> custom({
    Expression<int>? id,
    Expression<String>? thematic,
    Expression<String>? hymnalType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (thematic != null) 'thematic': thematic,
      if (hymnalType != null) 'hymnal_type': hymnalType,
    });
  }

  ThematicListsCompanion copyWith({
    Value<int>? id,
    Value<String>? thematic,
    Value<String>? hymnalType,
  }) {
    return ThematicListsCompanion(
      id: id ?? this.id,
      thematic: thematic ?? this.thematic,
      hymnalType: hymnalType ?? this.hymnalType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (thematic.present) {
      map['thematic'] = Variable<String>(thematic.value);
    }
    if (hymnalType.present) {
      map['hymnal_type'] = Variable<String>(hymnalType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThematicListsCompanion(')
          ..write('id: $id, ')
          ..write('thematic: $thematic, ')
          ..write('hymnalType: $hymnalType')
          ..write(')'))
        .toString();
  }
}

class $ThematicAmbitsTable extends ThematicAmbits
    with TableInfo<$ThematicAmbitsTable, ThematicAmbit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThematicAmbitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ambitMeta = const VerificationMeta('ambit');
  @override
  late final GeneratedColumn<String> ambit = GeneratedColumn<String>(
    'ambit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startNumberMeta = const VerificationMeta(
    'startNumber',
  );
  @override
  late final GeneratedColumn<int> startNumber = GeneratedColumn<int>(
    'start_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endNumberMeta = const VerificationMeta(
    'endNumber',
  );
  @override
  late final GeneratedColumn<int> endNumber = GeneratedColumn<int>(
    'end_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thematicListIdMeta = const VerificationMeta(
    'thematicListId',
  );
  @override
  late final GeneratedColumn<int> thematicListId = GeneratedColumn<int>(
    'thematic_list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES thematic_lists (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ambit,
    startNumber,
    endNumber,
    thematicListId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thematic_ambits';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThematicAmbit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ambit')) {
      context.handle(
        _ambitMeta,
        ambit.isAcceptableOrUnknown(data['ambit']!, _ambitMeta),
      );
    } else if (isInserting) {
      context.missing(_ambitMeta);
    }
    if (data.containsKey('start_number')) {
      context.handle(
        _startNumberMeta,
        startNumber.isAcceptableOrUnknown(
          data['start_number']!,
          _startNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startNumberMeta);
    }
    if (data.containsKey('end_number')) {
      context.handle(
        _endNumberMeta,
        endNumber.isAcceptableOrUnknown(data['end_number']!, _endNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_endNumberMeta);
    }
    if (data.containsKey('thematic_list_id')) {
      context.handle(
        _thematicListIdMeta,
        thematicListId.isAcceptableOrUnknown(
          data['thematic_list_id']!,
          _thematicListIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thematicListIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThematicAmbit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThematicAmbit(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      ambit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}ambit'],
          )!,
      startNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}start_number'],
          )!,
      endNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}end_number'],
          )!,
      thematicListId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}thematic_list_id'],
          )!,
    );
  }

  @override
  $ThematicAmbitsTable createAlias(String alias) {
    return $ThematicAmbitsTable(attachedDatabase, alias);
  }
}

class ThematicAmbit extends DataClass implements Insertable<ThematicAmbit> {
  final int id;
  final String ambit;
  final int startNumber;
  final int endNumber;
  final int thematicListId;
  const ThematicAmbit({
    required this.id,
    required this.ambit,
    required this.startNumber,
    required this.endNumber,
    required this.thematicListId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ambit'] = Variable<String>(ambit);
    map['start_number'] = Variable<int>(startNumber);
    map['end_number'] = Variable<int>(endNumber);
    map['thematic_list_id'] = Variable<int>(thematicListId);
    return map;
  }

  ThematicAmbitsCompanion toCompanion(bool nullToAbsent) {
    return ThematicAmbitsCompanion(
      id: Value(id),
      ambit: Value(ambit),
      startNumber: Value(startNumber),
      endNumber: Value(endNumber),
      thematicListId: Value(thematicListId),
    );
  }

  factory ThematicAmbit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThematicAmbit(
      id: serializer.fromJson<int>(json['id']),
      ambit: serializer.fromJson<String>(json['ambit']),
      startNumber: serializer.fromJson<int>(json['startNumber']),
      endNumber: serializer.fromJson<int>(json['endNumber']),
      thematicListId: serializer.fromJson<int>(json['thematicListId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ambit': serializer.toJson<String>(ambit),
      'startNumber': serializer.toJson<int>(startNumber),
      'endNumber': serializer.toJson<int>(endNumber),
      'thematicListId': serializer.toJson<int>(thematicListId),
    };
  }

  ThematicAmbit copyWith({
    int? id,
    String? ambit,
    int? startNumber,
    int? endNumber,
    int? thematicListId,
  }) => ThematicAmbit(
    id: id ?? this.id,
    ambit: ambit ?? this.ambit,
    startNumber: startNumber ?? this.startNumber,
    endNumber: endNumber ?? this.endNumber,
    thematicListId: thematicListId ?? this.thematicListId,
  );
  ThematicAmbit copyWithCompanion(ThematicAmbitsCompanion data) {
    return ThematicAmbit(
      id: data.id.present ? data.id.value : this.id,
      ambit: data.ambit.present ? data.ambit.value : this.ambit,
      startNumber:
          data.startNumber.present ? data.startNumber.value : this.startNumber,
      endNumber: data.endNumber.present ? data.endNumber.value : this.endNumber,
      thematicListId:
          data.thematicListId.present
              ? data.thematicListId.value
              : this.thematicListId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThematicAmbit(')
          ..write('id: $id, ')
          ..write('ambit: $ambit, ')
          ..write('startNumber: $startNumber, ')
          ..write('endNumber: $endNumber, ')
          ..write('thematicListId: $thematicListId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ambit, startNumber, endNumber, thematicListId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThematicAmbit &&
          other.id == this.id &&
          other.ambit == this.ambit &&
          other.startNumber == this.startNumber &&
          other.endNumber == this.endNumber &&
          other.thematicListId == this.thematicListId);
}

class ThematicAmbitsCompanion extends UpdateCompanion<ThematicAmbit> {
  final Value<int> id;
  final Value<String> ambit;
  final Value<int> startNumber;
  final Value<int> endNumber;
  final Value<int> thematicListId;
  const ThematicAmbitsCompanion({
    this.id = const Value.absent(),
    this.ambit = const Value.absent(),
    this.startNumber = const Value.absent(),
    this.endNumber = const Value.absent(),
    this.thematicListId = const Value.absent(),
  });
  ThematicAmbitsCompanion.insert({
    this.id = const Value.absent(),
    required String ambit,
    required int startNumber,
    required int endNumber,
    required int thematicListId,
  }) : ambit = Value(ambit),
       startNumber = Value(startNumber),
       endNumber = Value(endNumber),
       thematicListId = Value(thematicListId);
  static Insertable<ThematicAmbit> custom({
    Expression<int>? id,
    Expression<String>? ambit,
    Expression<int>? startNumber,
    Expression<int>? endNumber,
    Expression<int>? thematicListId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ambit != null) 'ambit': ambit,
      if (startNumber != null) 'start_number': startNumber,
      if (endNumber != null) 'end_number': endNumber,
      if (thematicListId != null) 'thematic_list_id': thematicListId,
    });
  }

  ThematicAmbitsCompanion copyWith({
    Value<int>? id,
    Value<String>? ambit,
    Value<int>? startNumber,
    Value<int>? endNumber,
    Value<int>? thematicListId,
  }) {
    return ThematicAmbitsCompanion(
      id: id ?? this.id,
      ambit: ambit ?? this.ambit,
      startNumber: startNumber ?? this.startNumber,
      endNumber: endNumber ?? this.endNumber,
      thematicListId: thematicListId ?? this.thematicListId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ambit.present) {
      map['ambit'] = Variable<String>(ambit.value);
    }
    if (startNumber.present) {
      map['start_number'] = Variable<int>(startNumber.value);
    }
    if (endNumber.present) {
      map['end_number'] = Variable<int>(endNumber.value);
    }
    if (thematicListId.present) {
      map['thematic_list_id'] = Variable<int>(thematicListId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThematicAmbitsCompanion(')
          ..write('id: $id, ')
          ..write('ambit: $ambit, ')
          ..write('startNumber: $startNumber, ')
          ..write('endNumber: $endNumber, ')
          ..write('thematicListId: $thematicListId')
          ..write(')'))
        .toString();
  }
}

class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _hymnNumberMeta = const VerificationMeta(
    'hymnNumber',
  );
  @override
  late final GeneratedColumn<int> hymnNumber = GeneratedColumn<int>(
    'hymn_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hymnalTypeMeta = const VerificationMeta(
    'hymnalType',
  );
  @override
  late final GeneratedColumn<String> hymnalType = GeneratedColumn<String>(
    'hymnal_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readingNumberMeta = const VerificationMeta(
    'readingNumber',
  );
  @override
  late final GeneratedColumn<int> readingNumber = GeneratedColumn<int>(
    'reading_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewedAtMeta = const VerificationMeta(
    'viewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> viewedAt = GeneratedColumn<DateTime>(
    'viewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hymnNumber,
    hymnalType,
    readingNumber,
    viewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hymn_number')) {
      context.handle(
        _hymnNumberMeta,
        hymnNumber.isAcceptableOrUnknown(data['hymn_number']!, _hymnNumberMeta),
      );
    }
    if (data.containsKey('hymnal_type')) {
      context.handle(
        _hymnalTypeMeta,
        hymnalType.isAcceptableOrUnknown(data['hymnal_type']!, _hymnalTypeMeta),
      );
    }
    if (data.containsKey('reading_number')) {
      context.handle(
        _readingNumberMeta,
        readingNumber.isAcceptableOrUnknown(
          data['reading_number']!,
          _readingNumberMeta,
        ),
      );
    }
    if (data.containsKey('viewed_at')) {
      context.handle(
        _viewedAtMeta,
        viewedAt.isAcceptableOrUnknown(data['viewed_at']!, _viewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_viewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      hymnNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hymn_number'],
      ),
      hymnalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hymnal_type'],
      ),
      readingNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reading_number'],
      ),
      viewedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}viewed_at'],
          )!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final int id;
  final int? hymnNumber;
  final String? hymnalType;
  final int? readingNumber;
  final DateTime viewedAt;
  const HistoryEntry({
    required this.id,
    this.hymnNumber,
    this.hymnalType,
    this.readingNumber,
    required this.viewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || hymnNumber != null) {
      map['hymn_number'] = Variable<int>(hymnNumber);
    }
    if (!nullToAbsent || hymnalType != null) {
      map['hymnal_type'] = Variable<String>(hymnalType);
    }
    if (!nullToAbsent || readingNumber != null) {
      map['reading_number'] = Variable<int>(readingNumber);
    }
    map['viewed_at'] = Variable<DateTime>(viewedAt);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      hymnNumber:
          hymnNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(hymnNumber),
      hymnalType:
          hymnalType == null && nullToAbsent
              ? const Value.absent()
              : Value(hymnalType),
      readingNumber:
          readingNumber == null && nullToAbsent
              ? const Value.absent()
              : Value(readingNumber),
      viewedAt: Value(viewedAt),
    );
  }

  factory HistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      hymnNumber: serializer.fromJson<int?>(json['hymnNumber']),
      hymnalType: serializer.fromJson<String?>(json['hymnalType']),
      readingNumber: serializer.fromJson<int?>(json['readingNumber']),
      viewedAt: serializer.fromJson<DateTime>(json['viewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hymnNumber': serializer.toJson<int?>(hymnNumber),
      'hymnalType': serializer.toJson<String?>(hymnalType),
      'readingNumber': serializer.toJson<int?>(readingNumber),
      'viewedAt': serializer.toJson<DateTime>(viewedAt),
    };
  }

  HistoryEntry copyWith({
    int? id,
    Value<int?> hymnNumber = const Value.absent(),
    Value<String?> hymnalType = const Value.absent(),
    Value<int?> readingNumber = const Value.absent(),
    DateTime? viewedAt,
  }) => HistoryEntry(
    id: id ?? this.id,
    hymnNumber: hymnNumber.present ? hymnNumber.value : this.hymnNumber,
    hymnalType: hymnalType.present ? hymnalType.value : this.hymnalType,
    readingNumber:
        readingNumber.present ? readingNumber.value : this.readingNumber,
    viewedAt: viewedAt ?? this.viewedAt,
  );
  HistoryEntry copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      hymnNumber:
          data.hymnNumber.present ? data.hymnNumber.value : this.hymnNumber,
      hymnalType:
          data.hymnalType.present ? data.hymnalType.value : this.hymnalType,
      readingNumber:
          data.readingNumber.present
              ? data.readingNumber.value
              : this.readingNumber,
      viewedAt: data.viewedAt.present ? data.viewedAt.value : this.viewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('id: $id, ')
          ..write('hymnNumber: $hymnNumber, ')
          ..write('hymnalType: $hymnalType, ')
          ..write('readingNumber: $readingNumber, ')
          ..write('viewedAt: $viewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, hymnNumber, hymnalType, readingNumber, viewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          other.id == this.id &&
          other.hymnNumber == this.hymnNumber &&
          other.hymnalType == this.hymnalType &&
          other.readingNumber == this.readingNumber &&
          other.viewedAt == this.viewedAt);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<int> id;
  final Value<int?> hymnNumber;
  final Value<String?> hymnalType;
  final Value<int?> readingNumber;
  final Value<DateTime> viewedAt;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.hymnNumber = const Value.absent(),
    this.hymnalType = const Value.absent(),
    this.readingNumber = const Value.absent(),
    this.viewedAt = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.hymnNumber = const Value.absent(),
    this.hymnalType = const Value.absent(),
    this.readingNumber = const Value.absent(),
    required DateTime viewedAt,
  }) : viewedAt = Value(viewedAt);
  static Insertable<HistoryEntry> custom({
    Expression<int>? id,
    Expression<int>? hymnNumber,
    Expression<String>? hymnalType,
    Expression<int>? readingNumber,
    Expression<DateTime>? viewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hymnNumber != null) 'hymn_number': hymnNumber,
      if (hymnalType != null) 'hymnal_type': hymnalType,
      if (readingNumber != null) 'reading_number': readingNumber,
      if (viewedAt != null) 'viewed_at': viewedAt,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<int?>? hymnNumber,
    Value<String?>? hymnalType,
    Value<int?>? readingNumber,
    Value<DateTime>? viewedAt,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      hymnNumber: hymnNumber ?? this.hymnNumber,
      hymnalType: hymnalType ?? this.hymnalType,
      readingNumber: readingNumber ?? this.readingNumber,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hymnNumber.present) {
      map['hymn_number'] = Variable<int>(hymnNumber.value);
    }
    if (hymnalType.present) {
      map['hymnal_type'] = Variable<String>(hymnalType.value);
    }
    if (readingNumber.present) {
      map['reading_number'] = Variable<int>(readingNumber.value);
    }
    if (viewedAt.present) {
      map['viewed_at'] = Variable<DateTime>(viewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('hymnNumber: $hymnNumber, ')
          ..write('hymnalType: $hymnalType, ')
          ..write('readingNumber: $readingNumber, ')
          ..write('viewedAt: $viewedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HymnsTable hymns = $HymnsTable(this);
  late final $ResponsiveReadingsTable responsiveReadings =
      $ResponsiveReadingsTable(this);
  late final $ThematicListsTable thematicLists = $ThematicListsTable(this);
  late final $ThematicAmbitsTable thematicAmbits = $ThematicAmbitsTable(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    hymns,
    responsiveReadings,
    thematicLists,
    thematicAmbits,
    historyEntries,
  ];
}

typedef $$HymnsTableCreateCompanionBuilder =
    HymnsCompanion Function({
      required int number,
      Value<String?> title,
      Value<String?> content,
      Value<String?> hymnalType,
      Value<bool?> isFavorite,
      Value<int> rowid,
    });
typedef $$HymnsTableUpdateCompanionBuilder =
    HymnsCompanion Function({
      Value<int> number,
      Value<String?> title,
      Value<String?> content,
      Value<String?> hymnalType,
      Value<bool?> isFavorite,
      Value<int> rowid,
    });

class $$HymnsTableFilterComposer extends Composer<_$AppDatabase, $HymnsTable> {
  $$HymnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HymnsTableOrderingComposer
    extends Composer<_$AppDatabase, $HymnsTable> {
  $$HymnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HymnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HymnsTable> {
  $$HymnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );
}

class $$HymnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HymnsTable,
          Hymn,
          $$HymnsTableFilterComposer,
          $$HymnsTableOrderingComposer,
          $$HymnsTableAnnotationComposer,
          $$HymnsTableCreateCompanionBuilder,
          $$HymnsTableUpdateCompanionBuilder,
          (Hymn, BaseReferences<_$AppDatabase, $HymnsTable, Hymn>),
          Hymn,
          PrefetchHooks Function()
        > {
  $$HymnsTableTableManager(_$AppDatabase db, $HymnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$HymnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$HymnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$HymnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> hymnalType = const Value.absent(),
                Value<bool?> isFavorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HymnsCompanion(
                number: number,
                title: title,
                content: content,
                hymnalType: hymnalType,
                isFavorite: isFavorite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int number,
                Value<String?> title = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> hymnalType = const Value.absent(),
                Value<bool?> isFavorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HymnsCompanion.insert(
                number: number,
                title: title,
                content: content,
                hymnalType: hymnalType,
                isFavorite: isFavorite,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HymnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HymnsTable,
      Hymn,
      $$HymnsTableFilterComposer,
      $$HymnsTableOrderingComposer,
      $$HymnsTableAnnotationComposer,
      $$HymnsTableCreateCompanionBuilder,
      $$HymnsTableUpdateCompanionBuilder,
      (Hymn, BaseReferences<_$AppDatabase, $HymnsTable, Hymn>),
      Hymn,
      PrefetchHooks Function()
    >;
typedef $$ResponsiveReadingsTableCreateCompanionBuilder =
    ResponsiveReadingsCompanion Function({
      Value<int> number,
      required String title,
      required String content,
      Value<bool?> isFavorite,
    });
typedef $$ResponsiveReadingsTableUpdateCompanionBuilder =
    ResponsiveReadingsCompanion Function({
      Value<int> number,
      Value<String> title,
      Value<String> content,
      Value<bool?> isFavorite,
    });

class $$ResponsiveReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ResponsiveReadingsTable> {
  $$ResponsiveReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResponsiveReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResponsiveReadingsTable> {
  $$ResponsiveReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResponsiveReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResponsiveReadingsTable> {
  $$ResponsiveReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );
}

class $$ResponsiveReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResponsiveReadingsTable,
          ResponsiveReading,
          $$ResponsiveReadingsTableFilterComposer,
          $$ResponsiveReadingsTableOrderingComposer,
          $$ResponsiveReadingsTableAnnotationComposer,
          $$ResponsiveReadingsTableCreateCompanionBuilder,
          $$ResponsiveReadingsTableUpdateCompanionBuilder,
          (
            ResponsiveReading,
            BaseReferences<
              _$AppDatabase,
              $ResponsiveReadingsTable,
              ResponsiveReading
            >,
          ),
          ResponsiveReading,
          PrefetchHooks Function()
        > {
  $$ResponsiveReadingsTableTableManager(
    _$AppDatabase db,
    $ResponsiveReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ResponsiveReadingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ResponsiveReadingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ResponsiveReadingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool?> isFavorite = const Value.absent(),
              }) => ResponsiveReadingsCompanion(
                number: number,
                title: title,
                content: content,
                isFavorite: isFavorite,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required String title,
                required String content,
                Value<bool?> isFavorite = const Value.absent(),
              }) => ResponsiveReadingsCompanion.insert(
                number: number,
                title: title,
                content: content,
                isFavorite: isFavorite,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResponsiveReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResponsiveReadingsTable,
      ResponsiveReading,
      $$ResponsiveReadingsTableFilterComposer,
      $$ResponsiveReadingsTableOrderingComposer,
      $$ResponsiveReadingsTableAnnotationComposer,
      $$ResponsiveReadingsTableCreateCompanionBuilder,
      $$ResponsiveReadingsTableUpdateCompanionBuilder,
      (
        ResponsiveReading,
        BaseReferences<
          _$AppDatabase,
          $ResponsiveReadingsTable,
          ResponsiveReading
        >,
      ),
      ResponsiveReading,
      PrefetchHooks Function()
    >;
typedef $$ThematicListsTableCreateCompanionBuilder =
    ThematicListsCompanion Function({
      Value<int> id,
      required String thematic,
      required String hymnalType,
    });
typedef $$ThematicListsTableUpdateCompanionBuilder =
    ThematicListsCompanion Function({
      Value<int> id,
      Value<String> thematic,
      Value<String> hymnalType,
    });

final class $$ThematicListsTableReferences
    extends BaseReferences<_$AppDatabase, $ThematicListsTable, ThematicList> {
  $$ThematicListsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ThematicAmbitsTable, List<ThematicAmbit>>
  _thematicAmbitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.thematicAmbits,
    aliasName: $_aliasNameGenerator(
      db.thematicLists.id,
      db.thematicAmbits.thematicListId,
    ),
  );

  $$ThematicAmbitsTableProcessedTableManager get thematicAmbitsRefs {
    final manager = $$ThematicAmbitsTableTableManager(
      $_db,
      $_db.thematicAmbits,
    ).filter((f) => f.thematicListId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_thematicAmbitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ThematicListsTableFilterComposer
    extends Composer<_$AppDatabase, $ThematicListsTable> {
  $$ThematicListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thematic => $composableBuilder(
    column: $table.thematic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> thematicAmbitsRefs(
    Expression<bool> Function($$ThematicAmbitsTableFilterComposer f) f,
  ) {
    final $$ThematicAmbitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.thematicAmbits,
      getReferencedColumn: (t) => t.thematicListId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThematicAmbitsTableFilterComposer(
            $db: $db,
            $table: $db.thematicAmbits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ThematicListsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThematicListsTable> {
  $$ThematicListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thematic => $composableBuilder(
    column: $table.thematic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThematicListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThematicListsTable> {
  $$ThematicListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get thematic =>
      $composableBuilder(column: $table.thematic, builder: (column) => column);

  GeneratedColumn<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => column,
  );

  Expression<T> thematicAmbitsRefs<T extends Object>(
    Expression<T> Function($$ThematicAmbitsTableAnnotationComposer a) f,
  ) {
    final $$ThematicAmbitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.thematicAmbits,
      getReferencedColumn: (t) => t.thematicListId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThematicAmbitsTableAnnotationComposer(
            $db: $db,
            $table: $db.thematicAmbits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ThematicListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThematicListsTable,
          ThematicList,
          $$ThematicListsTableFilterComposer,
          $$ThematicListsTableOrderingComposer,
          $$ThematicListsTableAnnotationComposer,
          $$ThematicListsTableCreateCompanionBuilder,
          $$ThematicListsTableUpdateCompanionBuilder,
          (ThematicList, $$ThematicListsTableReferences),
          ThematicList,
          PrefetchHooks Function({bool thematicAmbitsRefs})
        > {
  $$ThematicListsTableTableManager(_$AppDatabase db, $ThematicListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ThematicListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ThematicListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ThematicListsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> thematic = const Value.absent(),
                Value<String> hymnalType = const Value.absent(),
              }) => ThematicListsCompanion(
                id: id,
                thematic: thematic,
                hymnalType: hymnalType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String thematic,
                required String hymnalType,
              }) => ThematicListsCompanion.insert(
                id: id,
                thematic: thematic,
                hymnalType: hymnalType,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ThematicListsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({thematicAmbitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (thematicAmbitsRefs) db.thematicAmbits,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (thematicAmbitsRefs)
                    await $_getPrefetchedData<
                      ThematicList,
                      $ThematicListsTable,
                      ThematicAmbit
                    >(
                      currentTable: table,
                      referencedTable: $$ThematicListsTableReferences
                          ._thematicAmbitsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ThematicListsTableReferences(
                                db,
                                table,
                                p0,
                              ).thematicAmbitsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.thematicListId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ThematicListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThematicListsTable,
      ThematicList,
      $$ThematicListsTableFilterComposer,
      $$ThematicListsTableOrderingComposer,
      $$ThematicListsTableAnnotationComposer,
      $$ThematicListsTableCreateCompanionBuilder,
      $$ThematicListsTableUpdateCompanionBuilder,
      (ThematicList, $$ThematicListsTableReferences),
      ThematicList,
      PrefetchHooks Function({bool thematicAmbitsRefs})
    >;
typedef $$ThematicAmbitsTableCreateCompanionBuilder =
    ThematicAmbitsCompanion Function({
      Value<int> id,
      required String ambit,
      required int startNumber,
      required int endNumber,
      required int thematicListId,
    });
typedef $$ThematicAmbitsTableUpdateCompanionBuilder =
    ThematicAmbitsCompanion Function({
      Value<int> id,
      Value<String> ambit,
      Value<int> startNumber,
      Value<int> endNumber,
      Value<int> thematicListId,
    });

final class $$ThematicAmbitsTableReferences
    extends BaseReferences<_$AppDatabase, $ThematicAmbitsTable, ThematicAmbit> {
  $$ThematicAmbitsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ThematicListsTable _thematicListIdTable(_$AppDatabase db) =>
      db.thematicLists.createAlias(
        $_aliasNameGenerator(
          db.thematicAmbits.thematicListId,
          db.thematicLists.id,
        ),
      );

  $$ThematicListsTableProcessedTableManager get thematicListId {
    final $_column = $_itemColumn<int>('thematic_list_id')!;

    final manager = $$ThematicListsTableTableManager(
      $_db,
      $_db.thematicLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_thematicListIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ThematicAmbitsTableFilterComposer
    extends Composer<_$AppDatabase, $ThematicAmbitsTable> {
  $$ThematicAmbitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ambit => $composableBuilder(
    column: $table.ambit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startNumber => $composableBuilder(
    column: $table.startNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endNumber => $composableBuilder(
    column: $table.endNumber,
    builder: (column) => ColumnFilters(column),
  );

  $$ThematicListsTableFilterComposer get thematicListId {
    final $$ThematicListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.thematicListId,
      referencedTable: $db.thematicLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThematicListsTableFilterComposer(
            $db: $db,
            $table: $db.thematicLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThematicAmbitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThematicAmbitsTable> {
  $$ThematicAmbitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ambit => $composableBuilder(
    column: $table.ambit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startNumber => $composableBuilder(
    column: $table.startNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endNumber => $composableBuilder(
    column: $table.endNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$ThematicListsTableOrderingComposer get thematicListId {
    final $$ThematicListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.thematicListId,
      referencedTable: $db.thematicLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThematicListsTableOrderingComposer(
            $db: $db,
            $table: $db.thematicLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThematicAmbitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThematicAmbitsTable> {
  $$ThematicAmbitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ambit =>
      $composableBuilder(column: $table.ambit, builder: (column) => column);

  GeneratedColumn<int> get startNumber => $composableBuilder(
    column: $table.startNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endNumber =>
      $composableBuilder(column: $table.endNumber, builder: (column) => column);

  $$ThematicListsTableAnnotationComposer get thematicListId {
    final $$ThematicListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.thematicListId,
      referencedTable: $db.thematicLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThematicListsTableAnnotationComposer(
            $db: $db,
            $table: $db.thematicLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThematicAmbitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThematicAmbitsTable,
          ThematicAmbit,
          $$ThematicAmbitsTableFilterComposer,
          $$ThematicAmbitsTableOrderingComposer,
          $$ThematicAmbitsTableAnnotationComposer,
          $$ThematicAmbitsTableCreateCompanionBuilder,
          $$ThematicAmbitsTableUpdateCompanionBuilder,
          (ThematicAmbit, $$ThematicAmbitsTableReferences),
          ThematicAmbit,
          PrefetchHooks Function({bool thematicListId})
        > {
  $$ThematicAmbitsTableTableManager(
    _$AppDatabase db,
    $ThematicAmbitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ThematicAmbitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ThematicAmbitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ThematicAmbitsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ambit = const Value.absent(),
                Value<int> startNumber = const Value.absent(),
                Value<int> endNumber = const Value.absent(),
                Value<int> thematicListId = const Value.absent(),
              }) => ThematicAmbitsCompanion(
                id: id,
                ambit: ambit,
                startNumber: startNumber,
                endNumber: endNumber,
                thematicListId: thematicListId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ambit,
                required int startNumber,
                required int endNumber,
                required int thematicListId,
              }) => ThematicAmbitsCompanion.insert(
                id: id,
                ambit: ambit,
                startNumber: startNumber,
                endNumber: endNumber,
                thematicListId: thematicListId,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ThematicAmbitsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({thematicListId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (thematicListId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.thematicListId,
                            referencedTable: $$ThematicAmbitsTableReferences
                                ._thematicListIdTable(db),
                            referencedColumn:
                                $$ThematicAmbitsTableReferences
                                    ._thematicListIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ThematicAmbitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThematicAmbitsTable,
      ThematicAmbit,
      $$ThematicAmbitsTableFilterComposer,
      $$ThematicAmbitsTableOrderingComposer,
      $$ThematicAmbitsTableAnnotationComposer,
      $$ThematicAmbitsTableCreateCompanionBuilder,
      $$ThematicAmbitsTableUpdateCompanionBuilder,
      (ThematicAmbit, $$ThematicAmbitsTableReferences),
      ThematicAmbit,
      PrefetchHooks Function({bool thematicListId})
    >;
typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<int?> hymnNumber,
      Value<String?> hymnalType,
      Value<int?> readingNumber,
      required DateTime viewedAt,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<int?> hymnNumber,
      Value<String?> hymnalType,
      Value<int?> readingNumber,
      Value<DateTime> viewedAt,
    });

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hymnNumber => $composableBuilder(
    column: $table.hymnNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readingNumber => $composableBuilder(
    column: $table.readingNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get viewedAt => $composableBuilder(
    column: $table.viewedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hymnNumber => $composableBuilder(
    column: $table.hymnNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readingNumber => $composableBuilder(
    column: $table.readingNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get viewedAt => $composableBuilder(
    column: $table.viewedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get hymnNumber => $composableBuilder(
    column: $table.hymnNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hymnalType => $composableBuilder(
    column: $table.hymnalType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readingNumber => $composableBuilder(
    column: $table.readingNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get viewedAt =>
      $composableBuilder(column: $table.viewedAt, builder: (column) => column);
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEntriesTable,
          HistoryEntry,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (
            HistoryEntry,
            BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry>,
          ),
          HistoryEntry,
          PrefetchHooks Function()
        > {
  $$HistoryEntriesTableTableManager(
    _$AppDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$HistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> hymnNumber = const Value.absent(),
                Value<String?> hymnalType = const Value.absent(),
                Value<int?> readingNumber = const Value.absent(),
                Value<DateTime> viewedAt = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                hymnNumber: hymnNumber,
                hymnalType: hymnalType,
                readingNumber: readingNumber,
                viewedAt: viewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> hymnNumber = const Value.absent(),
                Value<String?> hymnalType = const Value.absent(),
                Value<int?> readingNumber = const Value.absent(),
                required DateTime viewedAt,
              }) => HistoryEntriesCompanion.insert(
                id: id,
                hymnNumber: hymnNumber,
                hymnalType: hymnalType,
                readingNumber: readingNumber,
                viewedAt: viewedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEntriesTable,
      HistoryEntry,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (
        HistoryEntry,
        BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry>,
      ),
      HistoryEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HymnsTableTableManager get hymns =>
      $$HymnsTableTableManager(_db, _db.hymns);
  $$ResponsiveReadingsTableTableManager get responsiveReadings =>
      $$ResponsiveReadingsTableTableManager(_db, _db.responsiveReadings);
  $$ThematicListsTableTableManager get thematicLists =>
      $$ThematicListsTableTableManager(_db, _db.thematicLists);
  $$ThematicAmbitsTableTableManager get thematicAmbits =>
      $$ThematicAmbitsTableTableManager(_db, _db.thematicAmbits);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
}
