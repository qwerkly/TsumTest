//
//  Moya_Extension.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 07.10.2021.
//

import Foundation
import Moya
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    
    /// Выполняет маппинг `Moya.Response`, используя в качестве
    /// стратегии `MappingStrategies.standard()`.
    /// Работает с `Decodable`-типами
    /// - Parameters:
    ///   - valueType: `Decodable`-тип модели
    ///   - errorType: `Decodable`-тип ошибки
    ///
    /// - Example: В данном примере Value: Decodable и Error: Decodable
    ///
    ///         provider
    ///             .rx
    ///             .request(.target)
    ///             .performMapping(
    ///                 valueType: MyModel.self,
    ///                 errorType: MyError.self
    ///              )
    func performMapping<Value: Decodable, Error: Swift.Error & Decodable>(
        valueType: Value.Type,
        errorType: Error.Type
    ) -> Single<Value> {
        return flatMap { response in
            return .just(try response.performMapping(
                valueType: Value.self,
                errorType: Error.self
            )
            )
        }
    }
    
    /// Выполняет маппинг `Moya.Response`
    /// - Parameters:
    ///   - valueMapping: маппинг возможной модели данных
    ///   - errorMapping: маппинг возможной ошибки
    ///   - mappingStrategy: стратегия маппинга
    func performMapping<Value, Error: Swift.Error>(
        valueMapping: @escaping Mapping<Value>,
        errorMapping: @escaping Mapping<Error>,
        mappingStrategy: @escaping MappingStrategy<Value, Error>
    ) -> Single<Value> {
        return flatMap { response -> Single<Value> in
            return .just(try response.performMapping(
                valueMapping: valueMapping,
                errorMapping: errorMapping,
                mappingStrategy: mappingStrategy
            )
            )
        }
    }
}

extension Moya.Response {
    /// Выполняет маппинг данных
    /// - Parameters:
    ///   - valueMapping: Используется для маппинга ожидаемой модели данных из `Moya.Response` в успешном запросе
    ///   - errorMapping: Используется для маппинга ожидаемой модели ошибки из `Moya.Response`
    ///   - mappingStrategy: Алгоритм, по которому выполняется разбор `Moya.Response`.
    ///   Он определяет порядок применения `valueMapping`, `errorMapping` и прочие условия
    func performMapping<Value, Error: Swift.Error>(
        valueMapping: @escaping Mapping<Value>,
        errorMapping: @escaping Mapping<Error>,
        mappingStrategy: @escaping MappingStrategy<Value, Error> = MappingStrategies.default()
    ) throws -> Value {
        return try mappingStrategy(self, valueMapping, errorMapping)
    }
    
    /// Выполняет маппинг Decodable-данных с учетом стандартизации API
    /// - Parameters:
    ///   - valueType: Тип Decodable-объекта
    ///   - errorType: Тип Decodable-ошибки
    ///   - valueMapping: Маппинг объекта
    ///   - errorMapping: Маппинг ошибки
    ///   - mappingStrategy: Стратегия маппинга
    func performMapping<Value: Decodable, Error: Decodable & Swift.Error>(
        valueType: Value.Type,
        errorType: Error.Type,
        valueMapping: @escaping Mapping<Value> = Mappings.decodable(Value.self),
        errorMapping: @escaping Mapping<Error> = Mappings.decodable(
                                                     Error.self,
                                                     atKeyPath: "error"
                                                 ),
        mappingStrategy: @escaping MappingStrategy<Value, Error> = MappingStrategies.standard()
    ) throws -> Value {
        return try performMapping(
            valueMapping: valueMapping,
            errorMapping: errorMapping,
            mappingStrategy: mappingStrategy
        )
    }
}

/// Производит маппинг данных из `Moya.Response` в модель `T`
typealias Mapping<T> = (Moya.Response) throws -> T

/// Namespace для всех фабрик mapping-замыканий.
///  - В случае необходимости добавить новый способ маппинга,
///   расширяем namespace новыми статическими функциями / переменными
enum Mappings {}

extension Mappings {
    
    /// Создает mapping-замыкание для Decodable-моделей
    /// - Parameters:
    ///   - type: тип модели
    ///   - keyPath: путь для маппинга модели внутри JSON-иерархии
    ///   - decoder: JSONDecoder
    ///   - failsOnEmptyData: воспринимать пустую `Data` в `Response` как ошибку. По-умолчанию `false`
    static func decodable<Value: Decodable>(
        _ type: Value.Type,
        atKeyPath keyPath: String? = nil,
        using decoder: JSONDecoder = JSONDecoder(),
        failsOnEmptyData: Bool = false
    ) -> Mapping<Value> {
        return { response in
            return try response.map(
                type,
                atKeyPath: keyPath,
                using: decoder,
                failsOnEmptyData: failsOnEmptyData
            )
        }
    }
}

/// Представляет собой алгоритм
///  маппинга данных.
/// Определяет в каком порядке будут вызваны конкретные мапперы
typealias MappingStrategy<Value, Error: Swift.Error>
    = (Moya.Response, Mapping<Value>, Mapping<Error>) throws -> Value

/// Namespace для добавления новых реализаций MappingStrategy.
enum MappingStrategies {}

extension MappingStrategies {
    
    /// Стратегия маппинга, основанная на статус кодах ответа
    static func `default`<Value, Error: Swift.Error>() -> MappingStrategy<Value, Error> {
        return { response, valueMapping, errorMapping in
            let isSuccessfulCode = (try? response.filterSuccessfulStatusCodes()) != nil
            
            do {
                let value = try valueMapping(response)
                
                return value
            } catch {
                if isSuccessfulCode {
                    throw MoyaError.objectMapping(error, response)
                }
                
                do {
                    let error = try errorMapping(response)
                    throw error
                } catch {
                    if error is Error {
                        throw error
                    } else {
                        throw MoyaError.objectMapping(error, response)
                    }
                }
            }
        }
    }
    
    /// Стратегия маппинга, основанная на установленном стандарте API
    static func standard<Value, Error: Swift.Error>() -> MappingStrategy<Value, Error> {
        return { response, valueMapping, errorMapping in
            let _ = try? JSONSerialization.jsonObject(
                with: response.data,
                options: .allowFragments
            ) as? [String: Any]
            
            let isSuccessfulCode = (try? response.filterSuccessfulStatusCodes()) != nil
            
            switch isSuccessfulCode {
                case true:
                    do {
                        let mappedValue = try valueMapping(response)
                        return mappedValue
                    } catch {
                        throw MoyaError.objectMapping(error, response)
                    }
                case false:
                    do {
                        let error = try errorMapping(response)
                        throw error
                    } catch {
                        if error is Error {
                            throw error
                        } else {
                            throw MoyaError.objectMapping(error, response)
                        }
                    }
            }
        }
    }
}
