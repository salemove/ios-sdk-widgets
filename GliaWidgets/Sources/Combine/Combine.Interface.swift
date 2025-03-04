//
//  This file contains a type‐erased Combine scheduler implementation,
//  heavily inspired by the CombineSchedulers library by Point-Free
//  (https://github.com/pointfreeco/combine-schedulers).
//
//  MIT License
//
//  Copyright (c) 2020 Point-Free, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import Combine

// MARK: - Type Eraser for Combine.Scheduler

/// A minimal type-erased scheduler for Combine that fixes the associated types
/// to those of DispatchQueue (i.e. SchedulerTimeType and SchedulerOptions).
/// This lets us wrap both DispatchQueue and our ImmediateScheduler in a common type.
struct AnyScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    private let _now: () -> SchedulerTimeType
    private let _minimumTolerance: () -> SchedulerTimeType.Stride
    private let _schedule: (
        SchedulerOptions?,
        @escaping () -> Void
    ) -> Void

    private let _scheduleAfter: (
        SchedulerTimeType,
        SchedulerTimeType.Stride,
        SchedulerOptions?,
        @escaping () -> Void
    ) -> Void

    private let _scheduleAfterInterval: (
        SchedulerTimeType,
        SchedulerTimeType.Stride,
        SchedulerTimeType.Stride,
        SchedulerOptions?,
        @escaping () -> Void
    ) -> Cancellable

    var now: SchedulerTimeType { _now() }
    var minimumTolerance: SchedulerTimeType.Stride { _minimumTolerance() }

    init<S: Scheduler>(_ scheduler: S) where S.SchedulerTimeType == SchedulerTimeType,
                                      S.SchedulerOptions == SchedulerOptions {
        _now = { scheduler.now }
        _minimumTolerance = { scheduler.minimumTolerance }
        _schedule = { options, action in scheduler.schedule(options: options, action) }
        _scheduleAfter = { date, tolerance, options, action in
            scheduler.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        _scheduleAfterInterval = { date, interval, tolerance, options, action in
            scheduler.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }

    func schedule(
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        _schedule(options, action)
    }

    func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        _scheduleAfter(date, tolerance, options, action)
    }

    func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        _scheduleAfterInterval(date, interval, tolerance, options, action)
    }
}

// MARK: - Immediate Scheduler for Testing

/// A scheduler that executes scheduled actions immediately. This is ideal for testing
/// since it avoids asynchronous delays.
struct ImmediateScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    var now: SchedulerTimeType { DispatchQueue.main.now }
    var minimumTolerance: SchedulerTimeType.Stride { .zero }

    func schedule(
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        action()
    }

    func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        action()
    }

    func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        action()
        return AnyCancellable {}
    }
}

struct AnyCombineScheduler {
    let main: AnyScheduler
    let global: AnyScheduler
}
