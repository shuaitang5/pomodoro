import Foundation

struct MenuBarPanelPositioning {
    static func panelOrigin(
        anchorRect: CGRect,
        visibleFrame: CGRect,
        panelSize: CGSize,
        screenInset: CGFloat,
        verticalSpacing: CGFloat
    ) -> CGPoint {
        let leftAlignedX = anchorRect.minX
        let rightAlignedX = anchorRect.maxX - panelSize.width
        let rightEdgeLimit = visibleFrame.maxX - panelSize.width - screenInset
        let shouldRightAlign = leftAlignedX > rightEdgeLimit

        var origin = CGPoint(
            x: shouldRightAlign ? rightAlignedX : leftAlignedX,
            y: anchorRect.minY - panelSize.height - verticalSpacing
        )

        origin.x = min(
            max(origin.x, visibleFrame.minX + screenInset),
            visibleFrame.maxX - panelSize.width - screenInset
        )
        origin.y = max(origin.y, visibleFrame.minY + screenInset)

        return origin
    }
}
