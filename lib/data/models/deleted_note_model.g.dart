// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_note_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeletedNoteModelCollection on Isar {
  IsarCollection<DeletedNoteModel> get deletedNoteModels => this.collection();
}

const DeletedNoteModelSchema = CollectionSchema(
  name: r'DeletedNoteModel',
  id: -3721984562567890123,
  properties: {
    r'noteId': PropertySchema(
      id: 0,
      name: r'noteId',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 1,
      name: r'title',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 2,
      name: r'content',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'isPinned': PropertySchema(
      id: 5,
      name: r'isPinned',
      type: IsarType.bool,
    ),
    r'folderId': PropertySchema(
      id: 6,
      name: r'folderId',
      type: IsarType.string,
    ),
    r'deletedAt': PropertySchema(
      id: 7,
      name: r'deletedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _deletedNoteModelEstimateSize,
  serialize: _deletedNoteModelSerialize,
  deserialize: _deletedNoteModelDeserialize,
  deserializeProp: _deletedNoteModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'noteId': IndexSchema(
      id: -1234567890123456789,
      name: r'noteId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'noteId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'deletedAt': IndexSchema(
      id: -9876543210987654321,
      name: r'deletedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'deletedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _deletedNoteModelGetId,
  getLinks: _deletedNoteModelGetLinks,
  attach: _deletedNoteModelAttach,
  version: '3.1.0+1',
);

int _deletedNoteModelEstimateSize(
  DeletedNoteModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.content.length * 3;
  {
    final value = object.folderId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _deletedNoteModelSerialize(
  DeletedNoteModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.noteId);
  writer.writeString(offsets[1], object.title);
  writer.writeString(offsets[2], object.content);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.updatedAt);
  writer.writeBool(offsets[5], object.isPinned);
  writer.writeString(offsets[6], object.folderId);
  writer.writeDateTime(offsets[7], object.deletedAt);
}

DeletedNoteModel _deletedNoteModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeletedNoteModel(
    noteId: reader.readLong(offsets[0]),
    title: reader.readString(offsets[1]),
    content: reader.readString(offsets[2]),
    createdAt: reader.readDateTime(offsets[3]),
    updatedAt: reader.readDateTimeOrNull(offsets[4]),
    isPinned: reader.readBoolOrNull(offsets[5]) ?? false,
    folderId: reader.readStringOrNull(offsets[6]),
    deletedAt: reader.readDateTime(offsets[7]),
    id: id,
  );
  return object;
}

P _deletedNoteModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deletedNoteModelGetId(DeletedNoteModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deletedNoteModelGetLinks(DeletedNoteModel object) {
  return [];
}

void _deletedNoteModelAttach(IsarCollection<dynamic> col, Id id, DeletedNoteModel object) {
  object.id = id;
}

extension DeletedNoteModelQueryWhereSort
    on QueryBuilder<DeletedNoteModel, DeletedNoteModel, QWhere> {
  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DeletedNoteModelQueryWhere
    on QueryBuilder<DeletedNoteModel, DeletedNoteModel, QWhereClause> {
  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterWhereClause> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.equalTo(
        value: value,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterWhereClause> idGreaterThan(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(
        value: value,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterWhereClause> idLessThan(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(
        value: value,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterWhereClause> idBetween(
    Id lower,
    Id upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lower,
        upper: upper,
      ));
    });
  }
}

extension DeletedNoteModelQueryFilter
    on QueryBuilder<DeletedNoteModel, DeletedNoteModel, QFilterCondition> {
  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterFilterCondition> noteIdEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'noteId',
        value: value,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterFilterCondition> titleEqualTo(
    String value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(QueryWhereCondition(
        property: r'title',
        value: value,
        method: QueryWhereConditionMethod.equalTo,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterFilterCondition> titleContains(
    String value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(QueryWhereCondition(
        property: r'title',
        value: value,
        method: QueryWhereConditionMethod.contains,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterFilterCondition> deletedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterFilterCondition> deletedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.greaterThan(
        indexName: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterFilterCondition> deletedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.lessThan(
        indexName: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterFilterCondition> deletedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deletedAt',
        lower: lower,
        upper: upper,
      ));
    });
  }
}

extension DeletedNoteModelQuerySort
    on QueryBuilder<DeletedNoteModel, DeletedNoteModel, QSortBy> {
  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterSortBy> sortByDeletedAt({
    bool ascending = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        r'deletedAt',
        ascending: ascending,
      );
    });
  }

  QueryBuilder<DeletedNoteModel, DeletedNoteModel, QAfterSortBy> sortByNoteId({
    bool ascending = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        r'noteId',
        ascending: ascending,
      );
    });
  }
}
