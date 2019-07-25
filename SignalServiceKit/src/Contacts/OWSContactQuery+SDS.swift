//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDBCipher
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct ContactQueryRecord: SDSRecord {
    public var tableMetadata: SDSTableMetadata {
        return OWSContactQuerySerializer.table
    }

    public static let databaseTableName: String = OWSContactQuerySerializer.table.tableName

    public var id: Int64?

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Base class properties
    public let lastQueried: Date
    public let nonce: Data

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case lastQueried
        case nonce
    }

    public static func columnName(_ column: ContactQueryRecord.CodingKeys, fullyQualified: Bool = false) -> String {
        return fullyQualified ? "\(databaseTableName).\(column.rawValue)" : column.rawValue
    }
}

// MARK: - StringInterpolation

public extension String.StringInterpolation {
    mutating func appendInterpolation(contactQueryColumn column: ContactQueryRecord.CodingKeys) {
        appendLiteral(ContactQueryRecord.columnName(column))
    }
    mutating func appendInterpolation(contactQueryColumnFullyQualified column: ContactQueryRecord.CodingKeys) {
        appendLiteral(ContactQueryRecord.columnName(column, fullyQualified: true))
    }
}

// MARK: - Deserialization

// TODO: Rework metadata to not include, for example, columns, column indices.
extension OWSContactQuery {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func fromRecord(_ record: ContactQueryRecord) throws -> OWSContactQuery {

        guard let recordId = record.id else {
            throw SDSError.invalidValue
        }

        switch record.recordType {
        case .contactQuery:

            let uniqueId: String = record.uniqueId
            let lastQueried: Date = record.lastQueried
            let nonce: Data = record.nonce

            return OWSContactQuery(uniqueId: uniqueId,
                                   lastQueried: lastQueried,
                                   nonce: nonce)

        default:
            owsFailDebug("Unexpected record type: \(record.recordType)")
            throw SDSError.invalidValue
        }
    }
}

// MARK: - SDSModel

extension OWSContactQuery: SDSModel {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return OWSContactQuerySerializer(model: self)
        }
    }

    public func asRecord() throws -> SDSRecord {
        return try serializer.asRecord()
    }
}

// MARK: - Table Metadata

extension OWSContactQuerySerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static let recordTypeColumn = SDSColumnMetadata(columnName: "recordType", columnType: .int, columnIndex: 0)
    static let idColumn = SDSColumnMetadata(columnName: "id", columnType: .primaryKey, columnIndex: 1)
    static let uniqueIdColumn = SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, columnIndex: 2)
    // Base class properties
    static let lastQueriedColumn = SDSColumnMetadata(columnName: "lastQueried", columnType: .int64, columnIndex: 3)
    static let nonceColumn = SDSColumnMetadata(columnName: "nonce", columnType: .blob, columnIndex: 4)

    // TODO: We should decide on a naming convention for
    //       tables that store models.
    public static let table = SDSTableMetadata(tableName: "model_OWSContactQuery", columns: [
        recordTypeColumn,
        idColumn,
        uniqueIdColumn,
        lastQueriedColumn,
        nonceColumn
        ])
}

// MARK: - Save/Remove/Update

@objc
public extension OWSContactQuery {
    func anyInsert(transaction: SDSAnyWriteTransaction) {
        sdsSave(saveMode: .insert, transaction: transaction)
    }

    // This method is private; we should never use it directly.
    // Instead, use anyUpdate(transaction:block:), so that we
    // use the "update with" pattern.
    private func anyUpdate(transaction: SDSAnyWriteTransaction) {
        sdsSave(saveMode: .update, transaction: transaction)
    }

    @available(*, deprecated, message: "Use anyInsert() or anyUpdate() instead.")
    func anyUpsert(transaction: SDSAnyWriteTransaction) {
        let isInserting: Bool
        if let uniqueId = uniqueId {
            if OWSContactQuery.anyFetch(uniqueId: uniqueId, transaction: transaction) != nil {
                isInserting = false
            } else {
                isInserting = true
            }
        } else {
            owsFailDebug("Missing uniqueId: \(type(of: self))")
            isInserting = true
        }
        sdsSave(saveMode: isInserting ? .insert : .update, transaction: transaction)
    }

    // This method is used by "updateWith..." methods.
    //
    // This model may be updated from many threads. We don't want to save
    // our local copy (this instance) since it may be out of date.  We also
    // want to avoid re-saving a model that has been deleted.  Therefore, we
    // use "updateWith..." methods to:
    //
    // a) Update a property of this instance.
    // b) If a copy of this model exists in the database, load an up-to-date copy,
    //    and update and save that copy.
    // b) If a copy of this model _DOES NOT_ exist in the database, do _NOT_ save
    //    this local instance.
    //
    // After "updateWith...":
    //
    // a) Any copy of this model in the database will have been updated.
    // b) The local property on this instance will always have been updated.
    // c) Other properties on this instance may be out of date.
    //
    // All mutable properties of this class have been made read-only to
    // prevent accidentally modifying them directly.
    //
    // This isn't a perfect arrangement, but in practice this will prevent
    // data loss and will resolve all known issues.
    func anyUpdate(transaction: SDSAnyWriteTransaction, block: (OWSContactQuery) -> Void) {
        guard let uniqueId = uniqueId else {
            owsFailDebug("Missing uniqueId.")
            return
        }

        block(self)

        guard let dbCopy = type(of: self).anyFetch(uniqueId: uniqueId,
                                                   transaction: transaction) else {
            return
        }

        // Don't apply the block twice to the same instance.
        // It's at least unnecessary and actually wrong for some blocks.
        // e.g. `block: { $0 in $0.someField++ }`
        if dbCopy !== self {
            block(dbCopy)
        }

        dbCopy.anyUpdate(transaction: transaction)
    }

    func anyRemove(transaction: SDSAnyWriteTransaction) {
        guard shouldBeSaved else {
            // Skipping remove.
            return
        }

        anyWillRemove(with: transaction)

        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            ydb_remove(with: ydbTransaction)
        case .grdbWrite(let grdbTransaction):
            do {
                let record = try asRecord()
                record.sdsRemove(transaction: grdbTransaction)
            } catch {
                owsFail("Remove failed: \(error)")
            }
        }

        anyDidRemove(with: transaction)
    }

    func anyReload(transaction: SDSAnyReadTransaction) {
        anyReload(transaction: transaction, ignoreMissing: false)
    }

    func anyReload(transaction: SDSAnyReadTransaction, ignoreMissing: Bool) {
        guard let uniqueId = self.uniqueId else {
            owsFailDebug("uniqueId was unexpectedly nil")
            return
        }

        guard let latestVersion = type(of: self).anyFetch(uniqueId: uniqueId, transaction: transaction) else {
            if !ignoreMissing {
                owsFailDebug("`latest` was unexpectedly nil")
            }
            return
        }

        setValuesForKeys(latestVersion.dictionaryValue)
    }
}

// MARK: - OWSContactQueryCursor

@objc
public class OWSContactQueryCursor: NSObject {
    private let cursor: RecordCursor<ContactQueryRecord>?

    init(cursor: RecordCursor<ContactQueryRecord>?) {
        self.cursor = cursor
    }

    public func next() throws -> OWSContactQuery? {
        guard let cursor = cursor else {
            return nil
        }
        guard let record = try cursor.next() else {
            return nil
        }
        return try OWSContactQuery.fromRecord(record)
    }

    public func all() throws -> [OWSContactQuery] {
        var result = [OWSContactQuery]()
        while true {
            guard let model = try next() else {
                break
            }
            result.append(model)
        }
        return result
    }
}

// MARK: - Obj-C Fetch

// TODO: We may eventually want to define some combination of:
//
// * fetchCursor, fetchOne, fetchAll, etc. (ala GRDB)
// * Optional "where clause" parameters for filtering.
// * Async flavors with completions.
//
// TODO: I've defined flavors that take a read transaction.
//       Or we might take a "connection" if we end up having that class.
@objc
public extension OWSContactQuery {
    class func grdbFetchCursor(transaction: GRDBReadTransaction) -> OWSContactQueryCursor {
        let database = transaction.database
        do {
            let cursor = try ContactQueryRecord.fetchCursor(database)
            return OWSContactQueryCursor(cursor: cursor)
        } catch {
            owsFailDebug("Read failed: \(error)")
            return OWSContactQueryCursor(cursor: nil)
        }
    }

    // Fetches a single model by "unique id".
    class func anyFetch(uniqueId: String,
                        transaction: SDSAnyReadTransaction) -> OWSContactQuery? {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return OWSContactQuery.ydb_fetch(uniqueId: uniqueId, transaction: ydbTransaction)
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT * FROM \(ContactQueryRecord.databaseTableName) WHERE \(contactQueryColumn: .uniqueId) = ?"
            return grdbFetchOne(sql: sql, arguments: [uniqueId], transaction: grdbTransaction)
        }
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    // Traversal aborts if the visitor returns false.
    class func anyEnumerate(transaction: SDSAnyReadTransaction, block: @escaping (OWSContactQuery, UnsafeMutablePointer<ObjCBool>) -> Void) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            OWSContactQuery.ydb_enumerateCollectionObjects(with: ydbTransaction) { (object, stop) in
                guard let value = object as? OWSContactQuery else {
                    owsFailDebug("unexpected object: \(type(of: object))")
                    return
                }
                block(value, stop)
            }
        case .grdbRead(let grdbTransaction):
            do {
                let cursor = OWSContactQuery.grdbFetchCursor(transaction: grdbTransaction)
                var stop: ObjCBool = false
                while let value = try cursor.next() {
                    block(value, &stop)
                    guard !stop.boolValue else {
                        break
                    }
                }
            } catch let error as NSError {
                owsFailDebug("Couldn't fetch models: \(error)")
            }
        }
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    // Traversal aborts if the visitor returns false.
    class func anyEnumerateUniqueIds(transaction: SDSAnyReadTransaction, block: @escaping (String, UnsafeMutablePointer<ObjCBool>) -> Void) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            ydbTransaction.enumerateKeys(inCollection: OWSContactQuery.collection()) { (uniqueId, stop) in
                block(uniqueId, stop)
            }
        case .grdbRead(let grdbTransaction):
            grdbEnumerateUniqueIds(transaction: grdbTransaction,
                                   sql: """
                    SELECT \(contactQueryColumn: .uniqueId)
                    FROM \(ContactQueryRecord.databaseTableName)
                """,
                block: block)
        }
    }

    // Does not order the results.
    class func anyFetchAll(transaction: SDSAnyReadTransaction) -> [OWSContactQuery] {
        var result = [OWSContactQuery]()
        anyEnumerate(transaction: transaction) { (model, _) in
            result.append(model)
        }
        return result
    }

    // Does not order the results.
    class func anyAllUniqueIds(transaction: SDSAnyReadTransaction) -> [String] {
        var result = [String]()
        anyEnumerateUniqueIds(transaction: transaction) { (uniqueId, _) in
            result.append(uniqueId)
        }
        return result
    }

    class func anyCount(transaction: SDSAnyReadTransaction) -> UInt {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return ydbTransaction.numberOfKeys(inCollection: OWSContactQuery.collection())
        case .grdbRead(let grdbTransaction):
            return ContactQueryRecord.ows_fetchCount(grdbTransaction.database)
        }
    }

    // WARNING: Do not use this method for any models which do cleanup
    //          in their anyWillRemove(), anyDidRemove() methods.
    class func anyRemoveAllWithoutInstantation(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            ydbTransaction.removeAllObjects(inCollection: OWSContactQuery.collection())
        case .grdbWrite(let grdbTransaction):
            do {
                try ContactQueryRecord.deleteAll(grdbTransaction.database)
            } catch {
                owsFailDebug("deleteAll() failed: \(error)")
            }
        }
    }

    class func anyRemoveAllWithInstantation(transaction: SDSAnyWriteTransaction) {
        anyEnumerate(transaction: transaction) { (instance, _) in
            instance.anyRemove(transaction: transaction)
        }
    }
}

// MARK: - Swift Fetch

public extension OWSContactQuery {
    class func grdbFetchCursor(sql: String,
                               arguments: [DatabaseValueConvertible]?,
                               transaction: GRDBReadTransaction) -> OWSContactQueryCursor {
        var statementArguments: StatementArguments?
        if let arguments = arguments {
            guard let statementArgs = StatementArguments(arguments) else {
                owsFailDebug("Could not convert arguments.")
                return OWSContactQueryCursor(cursor: nil)
            }
            statementArguments = statementArgs
        }
        let database = transaction.database
        do {
            let statement: SelectStatement = try database.cachedSelectStatement(sql: sql)
            let cursor = try ContactQueryRecord.fetchCursor(statement, arguments: statementArguments)
            return OWSContactQueryCursor(cursor: cursor)
        } catch {
            Logger.error("sql: \(sql)")
            owsFailDebug("Read failed: \(error)")
            return OWSContactQueryCursor(cursor: nil)
        }
    }

    class func grdbFetchOne(sql: String,
                            arguments: StatementArguments,
                            transaction: GRDBReadTransaction) -> OWSContactQuery? {
        assert(sql.count > 0)

        do {
            guard let record = try ContactQueryRecord.fetchOne(transaction.database, sql: sql, arguments: arguments) else {
                return nil
            }

            return try OWSContactQuery.fromRecord(record)
        } catch {
            owsFailDebug("error: \(error)")
            return nil
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class OWSContactQuerySerializer: SDSSerializer {

    private let model: OWSContactQuery
    public required init(model: OWSContactQuery) {
        self.model = model
    }

    // MARK: - Record

    func asRecord() throws -> SDSRecord {
        let id: Int64? = nil

        let recordType: SDSRecordType = .contactQuery
        guard let uniqueId: String = model.uniqueId else {
            owsFailDebug("Missing uniqueId.")
            throw SDSError.missingRequiredField
        }

        // Base class properties
        let lastQueried: Date = model.lastQueried
        let nonce: Data = model.nonce

        return ContactQueryRecord(id: id, recordType: recordType, uniqueId: uniqueId, lastQueried: lastQueried, nonce: nonce)
    }
}
