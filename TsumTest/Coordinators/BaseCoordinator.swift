//
//  BaseCoordinator.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 07.10.2021.
//

import Foundation
import RxSwift

public typealias Block<T> = (T) -> Void

/// Базовый класс. Содержит основные методы и механизмы для реализации концепции `parent -> child`
open class BaseCoordinator<ResultType> {

    // MARK: - Public properties
    
    /// Вызывается координатором в момент окончания его `Flow`
    /// С помощью данного callback-a
    public var onComplete: Block<ResultType>?

    // MARK: - Private properties
    
    /// Уникальный идентификатор координатора
    private let identifier = UUID()
    
    /// Словарь `child`-координаторов.
    /// Необходимо для поддержания жизненного цикла `child`-координатора.
    /// Координаторы образуют древовидную структуру
    private var childCoordinators: [UUID: Any] = [:]
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Public methods
    
    /// Запускает новый координатор. Удерживает ссылку на него с момента запуска и отпускает в момент
    /// окончания.
    /// Важно вызывать `super.coordinate(_:)` при переопределении метода.
    ///
    /// - Parameter coordinator: Стартующий координатор
    /// - Parameter action: `Action`-опция запуска
    open func coordinate<T>(to coordinator: BaseCoordinator<T>) {
        store(coordinator: coordinator)
        let completion = coordinator.onComplete
        coordinator.onComplete = { [weak self, weak coordinator] value in
            completion?(value)
            if let coordinator = coordinator {
                self?.free(coordinator: coordinator)
            }
        }
        coordinator.start()
    }

    /// Абстрактный метод. Запускает `Flow` координатора.
    open func start() {
        fatalError("❌ Метод обязательно должен был перегружен в наследнике.")
    }

    /// Освобождает все childCoordinators
    public func cleanUpChildCoordinators() {
        childCoordinators.removeAll()
    }
    
    // MARK: - Private methods
    
    private func store<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    private func free<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators.removeValue(forKey: coordinator.identifier)
    }
}

// MARK: - Default-ные имплементации

public extension BaseCoordinator {
    func onCompleteWhenClose(returning value: ResultType) -> Block<Void>{
        return { [weak self] _ in
            self?.onComplete?(value)
        }
    }
}
