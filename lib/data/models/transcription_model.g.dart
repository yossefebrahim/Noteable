// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTranscriptionModelCollection on Isar {
  IsarCollection<TranscriptionModel> get transcriptionModels =>
      this.collection();
}

const TranscriptionModelSchema = CollectionSchema(
  name: r'TranscriptionModel',
  id: -6410222194754967549,
  properties: {
    r'audioAttachmentId': PropertySchema(
      id: 0,
      name: r'audioAttachmentId',
      type: IsarType.long,
    ),
    r'confidence': PropertySchema(
      id: 1,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'text': PropertySchema(
      id: 2,
      name: r'text',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 3,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _transcriptionModelEstimateSize,
  serialize: _transcriptionModelSerialize,
  deserialize: _transcriptionModelDeserialize,
  deserializeProp: _transcriptionModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'confidence': IndexSchema(
      id: 2396183187517337286,
      name: r'confidence',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'confidence',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'audioAttachmentId': IndexSchema(
      id: -2016153950962004294,
      name: r'audioAttachmentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'audioAttachmentId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _transcriptionModelGetId,
  getLinks: _transcriptionModelGetLinks,
  attach: _transcriptionModelAttach,
  version: '3.1.0+1',
);

int _transcriptionModelEstimateSize(
  TranscriptionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _transcriptionModelSerialize(
  TranscriptionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.audioAttachmentId);
  writer.writeDouble(offsets[1], object.confidence);
  writer.writeString(offsets[2], object.text);
  writer.writeDateTime(offsets[3], object.timestamp);
}

TranscriptionModel _transcriptionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TranscriptionModel(
    audioAttachmentId: reader.readLongOrNull(offsets[0]),
    confidence: reader.readDouble(offsets[1]),
    id: id,
    text: reader.readString(offsets[2]),
    timestamp: reader.readDateTime(offsets[3]),
  );
  return object;
}

P _transcriptionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transcriptionModelGetId(TranscriptionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transcriptionModelGetLinks(
    TranscriptionModel object) {
  return [];
}

void _transcriptionModelAttach(
    IsarCollection<dynamic> col, Id id, TranscriptionModel object) {
  object.id = id;
}

extension TranscriptionModelQueryWhereSort
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QWhere> {
  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhere>
      anyConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'confidence'),
      );
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhere>
      anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhere>
      anyAudioAttachmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'audioAttachmentId'),
      );
    });
  }
}

extension TranscriptionModelQueryWhere
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QWhereClause> {
  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      confidenceEqualTo(double confidence) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'confidence',
        value: [confidence],
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      confidenceNotEqualTo(double confidence) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'confidence',
              lower: [],
              upper: [confidence],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'confidence',
              lower: [confidence],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'confidence',
              lower: [confidence],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'confidence',
              lower: [],
              upper: [confidence],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      confidenceGreaterThan(
    double confidence, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'confidence',
        lower: [confidence],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      confidenceLessThan(
    double confidence, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'confidence',
        lower: [],
        upper: [confidence],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      confidenceBetween(
    double lowerConfidence,
    double upperConfidence, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'confidence',
        lower: [lowerConfidence],
        includeLower: includeLower,
        upper: [upperConfidence],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      audioAttachmentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'audioAttachmentId',
        value: [null],
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      audioAttachmentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'audioAttachmentId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      audioAttachmentIdEqualTo(int? audioAttachmentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'audioAttachmentId',
        value: [audioAttachmentId],
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      audioAttachmentIdNotEqualTo(int? audioAttachmentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'audioAttachmentId',
              lower: [],
              upper: [audioAttachmentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'audioAttachmentId',
              lower: [audioAttachmentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'audioAttachmentId',
              lower: [audioAttachmentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'audioAttachmentId',
              lower: [],
              upper: [audioAttachmentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      audioAttachmentIdGreaterThan(
    int? audioAttachmentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'audioAttachmentId',
        lower: [audioAttachmentId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      audioAttachmentIdLessThan(
    int? audioAttachmentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'audioAttachmentId',
        lower: [],
        upper: [audioAttachmentId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterWhereClause>
      audioAttachmentIdBetween(
    int? lowerAudioAttachmentId,
    int? upperAudioAttachmentId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'audioAttachmentId',
        lower: [lowerAudioAttachmentId],
        includeLower: includeLower,
        upper: [upperAudioAttachmentId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TranscriptionModelQueryFilter
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QFilterCondition> {
  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      audioAttachmentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'audioAttachmentId',
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      audioAttachmentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'audioAttachmentId',
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      audioAttachmentIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioAttachmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      audioAttachmentIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioAttachmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      audioAttachmentIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioAttachmentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      audioAttachmentIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioAttachmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      confidenceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      confidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      confidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      confidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TranscriptionModelQueryObject
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QFilterCondition> {}

extension TranscriptionModelQueryLinks
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QFilterCondition> {}

extension TranscriptionModelQuerySortBy
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QSortBy> {
  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      sortByAudioAttachmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioAttachmentId', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      sortByAudioAttachmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioAttachmentId', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension TranscriptionModelQuerySortThenBy
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QSortThenBy> {
  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByAudioAttachmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioAttachmentId', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByAudioAttachmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioAttachmentId', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension TranscriptionModelQueryWhereDistinct
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QDistinct> {
  QueryBuilder<TranscriptionModel, TranscriptionModel, QDistinct>
      distinctByAudioAttachmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioAttachmentId');
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QDistinct>
      distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QDistinct>
      distinctByText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranscriptionModel, TranscriptionModel, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension TranscriptionModelQueryProperty
    on QueryBuilder<TranscriptionModel, TranscriptionModel, QQueryProperty> {
  QueryBuilder<TranscriptionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TranscriptionModel, int?, QQueryOperations>
      audioAttachmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioAttachmentId');
    });
  }

  QueryBuilder<TranscriptionModel, double, QQueryOperations>
      confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<TranscriptionModel, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<TranscriptionModel, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
