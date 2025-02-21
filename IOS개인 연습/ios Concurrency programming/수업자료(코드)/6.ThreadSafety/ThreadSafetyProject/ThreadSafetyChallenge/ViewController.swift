/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class ViewController: UIViewController {
    
  let changingNumber = Number(value: 0, name: "zero")
  let numberArray = [(1, "one"), (2, "two"), (3, "three"), (4, "four"), (5, "five"), (6, "six")]
  let workerQueue = DispatchQueue(label: "com.raywenderlich.worker", attributes: DispatchQueue.Attributes.concurrent)
    
  let numberGroup = DispatchGroup()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    changeNumber()
  }
  
  func changeNumber() {
    for pair in numberArray {
      workerQueue.async(group: numberGroup) {
        self.changingNumber.changeNumber(pair.0, name: pair.1)
        print("현재 숫자: \(self.changingNumber.number)")
      }
    }
    
    numberGroup.notify(queue: DispatchQueue.main) {
      print("마지막 숫자: \(self.changingNumber.number)")
    }
  }

}

