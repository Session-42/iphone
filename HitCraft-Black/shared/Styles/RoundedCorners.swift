import SwiftUI

struct RoundedCorners: Shape {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.size.width
        let height = rect.size.height
        
        // Make sure we do not exceed the size of the rectangle
        let topRight = min(min(self.topRight, height/2), width/2)
        let topLeft = min(min(self.topLeft, height/2), width/2)
        let bottomLeft = min(min(self.bottomLeft, height/2), width/2)
        let bottomRight = min(min(self.bottomRight, height/2), width/2)
        
        // Top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addArc(center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
                    radius: topLeft,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        // Top right corner
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
                    radius: topRight,
                    startAngle: Angle(degrees: 270),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        // Bottom right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addArc(center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
                    radius: bottomRight,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        // Bottom left corner
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
                    radius: bottomLeft,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        
        path.closeSubpath()
        
        return path
    }
}

// Example of using RoundedCorners
#Preview {
    VStack(spacing: 20) {
        Rectangle()
            .fill(HitCraftColors.accent)
            .frame(width: 200, height: 100)
            .clipShape(RoundedCorners(topLeft: 20, topRight: 20, bottomLeft: 0, bottomRight: 0))
        
        Rectangle()
            .fill(HitCraftColors.accent)
            .frame(width: 200, height: 100)
            .clipShape(RoundedCorners(topLeft: 0, topRight: 0, bottomLeft: 20, bottomRight: 20))
    }
    .padding()
}
