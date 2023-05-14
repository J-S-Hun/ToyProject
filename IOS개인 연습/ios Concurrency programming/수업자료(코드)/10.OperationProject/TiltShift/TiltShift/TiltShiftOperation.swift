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

// 🎾 커스텀 틸트쉬프트 "ImageFilterOperation" 클래스 (추상클래스에 오퍼레이션 이미지 필요에 관한 내용 정의)
class TiltShiftOperation : ImageFilterOperation {
    
    override func main() {
        if isCancelled { return }
        guard let inputImage = filterInput else { return }
        
        // 이미지 크기의 마스크 그라디언트
        if isCancelled { return }
        let mask = topAndBottomGradient(inputImage.size)
        
        // 블러처리, 마스크 이용해 처리하기
        if isCancelled { return }
        filterOutput = inputImage.applyBlurWithRadius(5, maskImage: mask)
    }
}
