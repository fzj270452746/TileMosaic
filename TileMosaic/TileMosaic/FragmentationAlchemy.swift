//
//  FragmentationAlchemy.swift
//  TileMosaic
//
//  Handles tile image slicing into puzzle pieces
//

import UIKit

class FragmentationAlchemy {

    static func dissectImageIntoFragments(image: UIImage, fragmentsPerAxis: Int) -> [[UIImage]] {
        guard let cgImage = image.cgImage else { return [] }

        let dimensionWidth = CGFloat(cgImage.width)
        let dimensionHeight = CGFloat(cgImage.height)

        let fragmentWidth = dimensionWidth / CGFloat(fragmentsPerAxis)
        let fragmentHeight = dimensionHeight / CGFloat(fragmentsPerAxis)

        var fragmentMatrix: [[UIImage]] = []

        for rowIndex in 0..<fragmentsPerAxis {
            var rowFragments: [UIImage] = []

            for columnIndex in 0..<fragmentsPerAxis {
                let originX = CGFloat(columnIndex) * fragmentWidth
                let originY = CGFloat(rowIndex) * fragmentHeight

                let rectangularRegion = CGRect(
                    x: originX,
                    y: originY,
                    width: fragmentWidth,
                    height: fragmentHeight
                )

                if let croppedCGImage = cgImage.cropping(to: rectangularRegion) {
                    let fragmentImage = UIImage(
                        cgImage: croppedCGImage,
                        scale: image.scale,
                        orientation: image.imageOrientation
                    )
                    rowFragments.append(fragmentImage)
                }
            }

            fragmentMatrix.append(rowFragments)
        }

        return fragmentMatrix
    }

    static func amalgamateFragmentsIntoImage(fragments: [[UIImage]]) -> UIImage? {
        guard !fragments.isEmpty, !fragments[0].isEmpty else { return nil }

        let rowQuantity = fragments.count
        let columnQuantity = fragments[0].count

        let fragmentDimension = fragments[0][0].size

        let totalWidth = fragmentDimension.width * CGFloat(columnQuantity)
        let totalHeight = fragmentDimension.height * CGFloat(rowQuantity)

        let canvasSize = CGSize(width: totalWidth, height: totalHeight)

        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        for (rowIndex, rowFragments) in fragments.enumerated() {
            for (columnIndex, fragment) in rowFragments.enumerated() {
                let originX = CGFloat(columnIndex) * fragmentDimension.width
                let originY = CGFloat(rowIndex) * fragmentDimension.height

                let rectangularRegion = CGRect(
                    x: originX,
                    y: originY,
                    width: fragmentDimension.width,
                    height: fragmentDimension.height
                )

                fragment.draw(in: rectangularRegion)
            }
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// Fragment data structure for puzzle
struct TessellationFragment {
    let fragmentImage: UIImage
    let correctRowPosition: Int
    let correctColumnPosition: Int
    var currentRowPosition: Int
    var currentColumnPosition: Int
    let uniqueIdentifier: String

    var isCorrectlyPositioned: Bool {
        return correctRowPosition == currentRowPosition && correctColumnPosition == currentColumnPosition
    }
}
