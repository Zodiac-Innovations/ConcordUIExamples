package com.zodiacinnovations.venueshowcase

object ConcordNative {
    init {
        System.loadLibrary("c++_shared")
        System.loadLibrary("ConcordUIAndroidApplication")
    }

    external fun setPlatformEnvironment()
    external fun setBannerEnvironment()
    external fun bannerDidDismiss()
    external fun start()
    external fun completeStandardAppStart()
    external fun elementType(path: String): Int
    external fun elementText(path: String): String
    external fun buttonFlavor(path: String): Int
    external fun buttonRole(path: String): Int
    external fun buttonIcon(path: String): String
    external fun titleActionFlavor(path: String): Int
    external fun titleActionLabel(path: String): String
    external fun titleActionImageKind(path: String): Int
    external fun titleActionImageName(path: String): String
    external fun titleActionCount(path: String): Int
    external fun titleActionTitle(path: String, index: Int): String
    external fun activateTitleAction(path: String, index: Int)
    external fun actionGroupTitle(path: String): String
    external fun actionGroupImageKind(path: String): Int
    external fun actionGroupImageName(path: String): String
    external fun actionGroupCount(path: String): Int
    external fun actionGroupItemTitle(path: String, index: Int): String
    external fun activateActionGroupItem(path: String, index: Int)
    external fun childCount(path: String): Int
    external fun containerEdge(path: String): Double
    external fun containerSpacing(path: String): Double
    external fun workBottomHeight(path: String): Double
    external fun justification(path: String): Int
    external fun isVisible(path: String): Boolean
    external fun isEnabled(path: String): Boolean
    external fun isReadOnly(path: String): Boolean
    external fun isRequired(path: String): Boolean
    external fun validationState(path: String): Int
    external fun requiredIndicator(path: String): Int
    external fun invalidIndicator(path: String): Int
    external fun helpText(path: String): String
    external fun errorText(path: String): String
    external fun isBold(path: String): Boolean
    external fun isItalic(path: String): Boolean
    external fun isUnderlined(path: String): Boolean
    external fun fontKind(path: String): Int
    external fun fontSize(path: String): Double
    external fun colorValue(path: String, role: Int): String
    external fun explicitColorValue(path: String, role: Int): String
    external fun widthRule(path: String): Int
    external fun heightRule(path: String): Int
    external fun fixedWidth(path: String): Double
    external fun fixedHeight(path: String): Double
    external fun boxWidth(path: String): Double
    external fun boxRadius(path: String): Double
    external fun boxPadding(path: String): Double
    external fun accessibilityText(path: String): String

    external fun boolFlavor(path: String): Int
    external fun boolControlSide(path: String): Int
    external fun boolState(path: String): Int
    external fun boolLabel(path: String): String
    external fun boolTrueName(path: String): String
    external fun boolFalseName(path: String): String
    external fun setBool(path: String, value: Boolean)

    external fun textFlavor(path: String): Int
    external fun textLabel(path: String): String
    external fun textPlaceholder(path: String): String
    external fun textValue(path: String): String
    external fun setText(path: String, value: String)

    external fun intFlavor(path: String): Int
    external fun intLabel(path: String): String
    external fun intPlaceholder(path: String): String
    external fun intHasValue(path: String): Boolean
    external fun intValue(path: String): Long
    external fun intHasRange(path: String): Boolean
    external fun intRangeLower(path: String): Long
    external fun intRangeUpper(path: String): Long
    external fun intStep(path: String): Long
    external fun setInt(path: String, value: Long)
    external fun clearInt(path: String)

    external fun floatFlavor(path: String): Int
    external fun floatLabel(path: String): String
    external fun floatPlaceholder(path: String): String
    external fun floatHasValue(path: String): Boolean
    external fun floatValue(path: String): Double
    external fun floatHasRange(path: String): Boolean
    external fun floatRangeLower(path: String): Double
    external fun floatRangeUpper(path: String): Double
    external fun floatStep(path: String): Double
    external fun setFloat(path: String, value: Double)
    external fun clearFloat(path: String)

    external fun dateFlavor(path: String): Int
    external fun dateLabel(path: String): String
    external fun dateHasValue(path: String): Boolean
    external fun dateValue(path: String): Double
    external fun dateMinimum(path: String): Double
    external fun dateMaximum(path: String): Double
    external fun setDateValue(path: String, value: Double)
    external fun clearDateValue(path: String)

    external fun imageKind(path: String): Int
    external fun imageName(path: String): String
    external fun rasterWidth(path: String): Double
    external fun rasterHeight(path: String): Double
    external fun rasterImageCount(path: String, width: Double, height: Double): Int
    external fun rasterImageKind(path: String, index: Int, width: Double, height: Double): Int
    external fun rasterImageName(path: String, index: Int, width: Double, height: Double): String
    external fun rasterImageX(path: String, index: Int, width: Double, height: Double): Double
    external fun rasterImageY(path: String, index: Int, width: Double, height: Double): Double
    external fun rasterImageWidth(path: String, index: Int, width: Double, height: Double): Double
    external fun rasterImageHeight(path: String, index: Int, width: Double, height: Double): Double
    external fun rasterImageZOrder(path: String, index: Int, width: Double, height: Double): Int
    external fun rasterImageContentMode(path: String, index: Int, width: Double, height: Double): Int
    external fun progressFlavor(path: String): Int
    external fun progressLabel(path: String): String
    external fun progressValue(path: String): Double

    external fun selectionFlavor(path: String): Int
    external fun selectionLabel(path: String): String
    external fun selectionCount(path: String): Int
    external fun selectionIndex(path: String): Int
    external fun selectionItemText(path: String, index: Int): String
    external fun setSelectionIndex(path: String, index: Int)

    external fun expanderFlavor(path: String): Int
    external fun expanderLabel(path: String): String
    external fun expanderExpanded(path: String): Boolean
    external fun expanderOnRight(path: String): Boolean
    external fun toggleExpander(path: String)

    external fun activate(path: String)
}