package com.zodiacinnovations.platformshowcase

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.content.res.Configuration
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.compose.ui.unit.sp
import java.text.DateFormat
import java.util.Calendar
import java.util.Date
import kotlin.math.round

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ConcordNative.start()
        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    var revision by remember { mutableIntStateOf(0) }
                    LaunchedEffect(Unit) {
                        ConcordNative.completeStandardAppStart()
                        revision += 1
                    }
                    val hostModifier = Modifier
                        .fillMaxSize()
                        .safeDrawingPadding()
                        .imePadding()
                        .padding(horizontal = 10.dp)
                    val scrollState = rememberScrollState()
                    Box(modifier = hostModifier, contentAlignment = Alignment.TopStart) {
                        key(revision) {
                            if (ConcordNative.heightRule("") == 3) {
                                ConcordElement("", false, revision, { revision += 1 })
                            } else {
                                Box(
                                    modifier = Modifier.fillMaxSize().verticalScroll(scrollState),
                                    contentAlignment = Alignment.TopStart
                                ) {
                                    ConcordElement("", false, revision, { revision += 1 })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun concordColor(path: String, role: Int, explicit: Boolean = false): Color? {
    val value = if (explicit) ConcordNative.explicitColorValue(path, role) else ConcordNative.colorValue(path, role)
    if (value.isEmpty()) return null
    if (value.startsWith("semantic:")) {
        return when (value.removePrefix("semantic:")) {
            "primary" -> MaterialTheme.colorScheme.onSurface
            "secondary" -> MaterialTheme.colorScheme.onSurfaceVariant
            "accent" -> MaterialTheme.colorScheme.primary
            "background" -> MaterialTheme.colorScheme.background
            "error" -> MaterialTheme.colorScheme.error
            "warning" -> Color(0xFFFFA000)
            "success" -> Color(0xFF2E7D32)
            else -> null
        }
    }
    if (value.startsWith("rgba:")) {
        val parts = value.removePrefix("rgba:").split(',').mapNotNull { it.toFloatOrNull() }
        if (parts.size == 4) return Color(parts[0], parts[1], parts[2], parts[3])
    }
    return null
}

@Composable
private fun ConcordElement(
    path: String,
    parentHorizontal: Boolean,
    revision: Int,
    refresh: () -> Unit,
    layoutModifier: Modifier = Modifier
) {
    revision
    if (!ConcordNative.isVisible(path)) return
    val base = layoutModifier.then(concordModifier(path))
    val aligned = when (ConcordNative.justification(path)) {
        2 -> Modifier.fillMaxWidth().wrapContentWidth(Alignment.CenterHorizontally).then(base)
        3 -> Modifier.fillMaxWidth().wrapContentWidth(Alignment.End).then(base)
        else -> base
    }
    val fontFamily = when (ConcordNative.fontKind(path)) {
        1 -> FontFamily.Default
        2 -> FontFamily.Monospace
        else -> LocalTextStyle.current.fontFamily
    }
    val fontSize = ConcordNative.fontSize(path).coerceAtLeast(1.0).toFloat().sp
    val foreground = concordColor(path, 1) ?: LocalContentColor.current
    CompositionLocalProvider(
        LocalContentColor provides foreground,
        LocalTextStyle provides LocalTextStyle.current.copy(fontFamily = fontFamily, fontSize = fontSize)
    ) {
        when (ConcordNative.elementType(path)) {
            1 -> ConcordLabel(path, aligned)
            2 -> ConcordButton(path, aligned, refresh)
            3 -> ConcordVStack(path, aligned, revision, refresh)
            4 -> ConcordHStack(path, aligned, revision, refresh)
            19 -> ConcordABStack(path, aligned, revision, refresh)
            20 -> ConcordWorkStack(path, aligned, revision, refresh)
            5 -> if (parentHorizontal) Spacer(aligned.width(1.dp)) else Spacer(aligned.height(1.dp))
            6, 17 -> if (parentHorizontal) VerticalDivider(modifier = aligned, color = foreground) else HorizontalDivider(modifier = aligned, color = foreground)
            7 -> ConcordBool(path, aligned, refresh)
            8 -> ConcordTextInput(path, aligned, refresh)
            9 -> ConcordIntInput(path, aligned, refresh)
            10 -> ConcordFloatInput(path, aligned, refresh)
            11, 12, 13 -> ConcordDateTimeInput(path, aligned, ConcordNative.elementType(path), refresh)
            14 -> ConcordImage(path, aligned)
            15 -> ConcordProgress(path, aligned)
            16 -> ConcordSelection(path, aligned, refresh)
            18 -> ConcordExpander(path, aligned, revision, refresh)
            21 -> ConcordRaster(path, aligned)
            22 -> ConcordTitleActions(path, aligned, refresh)
            23 -> ConcordActionGroup(path, aligned, refresh)
        }
    }
}

@Composable
private fun concordModifier(path: String): Modifier {
    var modifier: Modifier = Modifier
    when (ConcordNative.widthRule(path)) {
        2 -> modifier = modifier.width(ConcordNative.fixedWidth(path).dp)
        3 -> modifier = modifier.fillMaxWidth()
    }
    when (ConcordNative.heightRule(path)) {
        2 -> modifier = modifier.height(ConcordNative.fixedHeight(path).dp)
        3 -> modifier = modifier.fillMaxHeight()
    }
    concordColor(path, 2)?.let { modifier = modifier.background(it) }
    val boxWidth = ConcordNative.boxWidth(path)
    if (boxWidth > 0) {
        val frame = concordColor(path, 3) ?: MaterialTheme.colorScheme.outline
        modifier = modifier
            .border(boxWidth.dp, frame, RoundedCornerShape(ConcordNative.boxRadius(path).dp))
            .padding(ConcordNative.boxPadding(path).dp)
    }
    val invalidIndicator = ConcordNative.invalidIndicator(path)
    if (ConcordNative.validationState(path) == 2 && (invalidIndicator == 2 || invalidIndicator == 3)) {
        modifier = modifier
            .border(1.dp, MaterialTheme.colorScheme.error, RoundedCornerShape(6.dp))
            .padding(3.dp)
    }
    val accessibility = ConcordNative.accessibilityText(path)
    if (accessibility.isNotEmpty()) modifier = modifier.semantics { contentDescription = accessibility }
    return modifier
}

@Composable
private fun ConcordVStack(path: String, modifier: Modifier, revision: Int, refresh: () -> Unit) {
    Column(
        modifier = modifier.padding(ConcordNative.containerEdge(path).dp),
        horizontalAlignment = Alignment.Start,
        verticalArrangement = Arrangement.spacedBy(ConcordNative.containerSpacing(path).dp)
    ) {
        repeat(ConcordNative.childCount(path)) { index ->
            val child = childPath(path, index)
            if (ConcordNative.elementType(child) == 5) {
                if (ConcordNative.heightRule(child) == 2) Spacer(Modifier.height(ConcordNative.fixedHeight(child).dp))
                else Spacer(Modifier.weight(1f))
            } else ConcordElement(child, false, revision, refresh)
        }
    }
}

@Composable
private fun ConcordHStack(path: String, modifier: Modifier, revision: Int, refresh: () -> Unit) {
    Row(
        modifier = modifier.padding(ConcordNative.containerEdge(path).dp),
        verticalAlignment = Alignment.Top,
        horizontalArrangement = Arrangement.spacedBy(ConcordNative.containerSpacing(path).dp)
    ) {
        repeat(ConcordNative.childCount(path)) { index ->
            val child = childPath(path, index)
            if (ConcordNative.elementType(child) == 5) {
                if (ConcordNative.widthRule(child) == 2) Spacer(Modifier.width(ConcordNative.fixedWidth(child).dp))
                else Spacer(Modifier.weight(1f))
            } else ConcordElement(child, true, revision, refresh)
        }
    }
}

@Composable
private fun ConcordWorkStack(path: String, modifier: Modifier, revision: Int, refresh: () -> Unit) {
    val bottomPath = childPath(path, 1)
    val bottomAlignment = when (ConcordNative.justification(bottomPath)) {
        2 -> Alignment.CenterHorizontally
        3 -> Alignment.End
        else -> Alignment.Start
    }
    Column(
        modifier = modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.Start,
        verticalArrangement = Arrangement.spacedBy(ConcordNative.containerSpacing(bottomPath).dp)
    ) {
        ConcordElement(
            childPath(path, 0),
            false,
            revision,
            refresh,
            Modifier.fillMaxWidth()
        )
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .then(
                    concordColor(bottomPath, 2)
                        ?.let { Modifier.background(it) }
                        ?: Modifier
                ),
            horizontalAlignment = bottomAlignment
        ) {
            repeat(ConcordNative.childCount(bottomPath)) { index ->
                ConcordElement(
                    childPath(bottomPath, index),
                    false,
                    revision,
                    refresh,
                    Modifier.fillMaxWidth().wrapContentWidth(bottomAlignment)
                )
            }
        }
    }
}

@Composable
private fun ConcordABStack(path: String, modifier: Modifier, revision: Int, refresh: () -> Unit) {
    val edge = ConcordNative.containerEdge(path).dp
    val spacing = ConcordNative.containerSpacing(path).dp
    val isLandscape = LocalConfiguration.current.orientation == Configuration.ORIENTATION_LANDSCAPE
    if (isLandscape) {
        Row(
            modifier = modifier.padding(edge).fillMaxWidth(),
            verticalAlignment = Alignment.Top,
            horizontalArrangement = Arrangement.spacedBy(spacing)
        ) {
            ConcordElement(childPath(path, 0), true, revision, refresh, Modifier.weight(1f))
            ConcordElement(childPath(path, 1), true, revision, refresh, Modifier.weight(1f))
        }
    } else {
        Column(
            modifier = modifier.padding(edge).fillMaxWidth(),
            horizontalAlignment = Alignment.Start,
            verticalArrangement = Arrangement.spacedBy(spacing)
        ) {
            ConcordElement(childPath(path, 0), false, revision, refresh)
            ConcordElement(childPath(path, 1), false, revision, refresh)
        }
    }
}

@Composable
private fun RequiredLabel(path: String, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(label)
        if (ConcordNative.isRequired(path) && ConcordNative.requiredIndicator(path) == 1) {
            Text(" *", color = MaterialTheme.colorScheme.error)
        }
    }
}

@Composable
private fun ConcordMetadata(path: String) {
    val help = ConcordNative.helpText(path)
    val error = ConcordNative.errorText(path)
    val invalidIndicator = ConcordNative.invalidIndicator(path)
    if (ConcordNative.isRequired(path) && ConcordNative.requiredIndicator(path) == 2) {
        Text("Required", style = MaterialTheme.typography.labelSmall)
    }
    if (help.isNotEmpty()) Text(help, style = MaterialTheme.typography.labelSmall)
    if (
        ConcordNative.validationState(path) == 2 &&
        (invalidIndicator == 1 || invalidIndicator == 3) &&
        error.isNotEmpty()
    ) {
        Text(error, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.error)
    }
}

@Composable
private fun ConcordLabel(path: String, modifier: Modifier) {
    Text(
        text = ConcordNative.elementText(path), modifier = modifier,
        textAlign = when (ConcordNative.justification(path)) {
            2 -> TextAlign.Center
            3 -> TextAlign.End
            else -> TextAlign.Start
        },
        fontWeight = if (ConcordNative.isBold(path)) FontWeight.Bold else FontWeight.Normal,
        fontStyle = if (ConcordNative.isItalic(path)) FontStyle.Italic else FontStyle.Normal,
        textDecoration = if (ConcordNative.isUnderlined(path)) TextDecoration.Underline else TextDecoration.None
    )
}

private fun concordIcon(name: String): ImageVector = when (name) {
    "app" -> Icons.Filled.Apps
    "home" -> Icons.Filled.Home
    "settings" -> Icons.Filled.Settings
    "information" -> Icons.Filled.Info
    "welcome" -> Icons.Filled.WavingHand
    "getStarted" -> Icons.Filled.PlayCircle
    "whatsNew" -> Icons.Filled.AutoAwesome
    "faq" -> Icons.Filled.HelpOutline
    "help" -> Icons.Filled.SupportAgent
    "search" -> Icons.Filled.Search
    "add" -> Icons.Filled.Add
    "remove" -> Icons.Filled.Remove
    "check" -> Icons.Filled.Check
    "warning" -> Icons.Filled.Warning
    "error" -> Icons.Filled.Error
    else -> Icons.Filled.Info
}

@Composable
private fun ConcordButton(path: String, modifier: Modifier, refresh: () -> Unit) {
    val foreground = concordColor(path, 1, explicit = true)
    val background = concordColor(path, 2, explicit = true)
    val enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path)
    val destructive = ConcordNative.buttonRole(path) == 4
    val activate = { ConcordNative.activate(path); refresh() }

    when (ConcordNative.buttonFlavor(path)) {
        2 -> {
            val colors = if (foreground != null || background != null) ButtonDefaults.buttonColors(
                containerColor = background ?: if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary,
                contentColor = foreground ?: if (destructive) MaterialTheme.colorScheme.onError else MaterialTheme.colorScheme.onPrimary
            ) else ButtonDefaults.buttonColors()
            Button(modifier = modifier, colors = colors, enabled = enabled, onClick = activate) {
                Text(ConcordNative.elementText(path), color = LocalContentColor.current)
            }
        }
        3 -> {
            val colors = if (foreground != null || destructive) IconButtonDefaults.iconButtonColors(
                contentColor = foreground ?: MaterialTheme.colorScheme.error
            ) else IconButtonDefaults.iconButtonColors()
            IconButton(modifier = modifier, colors = colors, enabled = enabled, onClick = activate) {
                Icon(
                    imageVector = concordIcon(ConcordNative.buttonIcon(path)),
                    contentDescription = ConcordNative.accessibilityText(path).ifEmpty { ConcordNative.elementText(path) }
                )
            }
        }
        4 -> {
            val colors = if (foreground != null || background != null) ButtonDefaults.textButtonColors(
                containerColor = background ?: Color.Transparent,
                contentColor = foreground ?: if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary
            ) else ButtonDefaults.textButtonColors()
            TextButton(modifier = modifier, colors = colors, enabled = enabled, onClick = activate) {
                Text(ConcordNative.elementText(path), color = LocalContentColor.current)
                Spacer(Modifier.width(6.dp))
                Icon(
                    imageVector = concordIcon(ConcordNative.buttonIcon(path)),
                    contentDescription = null,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
        else -> {
            val colors = if (foreground != null || background != null) ButtonDefaults.textButtonColors(
                containerColor = background ?: Color.Transparent,
                contentColor = foreground ?: if (destructive) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary
            ) else ButtonDefaults.textButtonColors()
            TextButton(modifier = modifier, colors = colors, enabled = enabled, onClick = activate) {
                Text(ConcordNative.elementText(path), color = LocalContentColor.current)
            }
        }
    }
}

@Composable
private fun ConcordTitleActions(path: String, modifier: Modifier, refresh: () -> Unit) {
    val count = ConcordNative.titleActionCount(path)
    val enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path)
    val activate: (Int) -> Unit = { index ->
        ConcordNative.activateTitleAction(path, index)
        refresh()
    }

    when (ConcordNative.titleActionFlavor(path)) {
        1 -> Column(
            modifier = modifier.padding(ConcordNative.containerEdge(path).dp),
            horizontalAlignment = Alignment.Start,
            verticalArrangement = Arrangement.spacedBy(ConcordNative.containerSpacing(path).dp)
        ) {
            repeat(count) { index ->
                Button(enabled = enabled, onClick = { activate(index) }) {
                    Text(ConcordNative.titleActionTitle(path, index))
                }
            }
        }
        2 -> Row(
            modifier = modifier.padding(ConcordNative.containerEdge(path).dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(ConcordNative.containerSpacing(path).dp)
        ) {
            repeat(count) { index ->
                Button(enabled = enabled, onClick = { activate(index) }) {
                    Text(ConcordNative.titleActionTitle(path, index))
                }
            }
        }
        3 -> {
            var expanded by remember(path) { mutableStateOf(false) }
            Box(modifier = modifier.padding(ConcordNative.containerEdge(path).dp)) {
                Button(enabled = enabled, onClick = { expanded = true }) {
                    val imageKind = ConcordNative.titleActionImageKind(path)
                    if (imageKind != 0) {
                        ConcordRasterImage(
                            kind = imageKind,
                            name = ConcordNative.titleActionImageName(path),
                            contentScale = ContentScale.Fit,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    val label = ConcordNative.titleActionLabel(path)
                    if (label.isNotEmpty()) {
                        if (imageKind != 0) Spacer(Modifier.width(6.dp))
                        Text(label)
                    }
                }
                DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
                    repeat(count) { index ->
                        DropdownMenuItem(
                            text = { Text(ConcordNative.titleActionTitle(path, index)) },
                            onClick = {
                                expanded = false
                                activate(index)
                            }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ConcordActionGroup(path: String, modifier: Modifier, refresh: () -> Unit) {
    val count = ConcordNative.actionGroupCount(path)
    if (count == 0) return

    var expanded by remember(path) { mutableStateOf(false) }
    Box(modifier = modifier) {
        Button(
            enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path),
            onClick = { expanded = true }
        ) {
            val imageKind = ConcordNative.actionGroupImageKind(path)
            if (imageKind != 0) {
                ConcordRasterImage(
                    kind = imageKind,
                    name = ConcordNative.actionGroupImageName(path),
                    contentScale = ContentScale.Fit,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(Modifier.width(6.dp))
            }
            Text(ConcordNative.actionGroupTitle(path))
        }
        DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
            repeat(count) { index ->
                DropdownMenuItem(
                    text = { Text(ConcordNative.actionGroupItemTitle(path, index)) },
                    onClick = {
                        expanded = false
                        ConcordNative.activateActionGroupItem(path, index)
                        refresh()
                    }
                )
            }
        }
    }
}

@Composable
private fun ConcordBool(path: String, modifier: Modifier, refresh: () -> Unit) {
    val state = ConcordNative.boolState(path)
    val enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path)
    val label = ConcordNative.boolLabel(path)
    val controlOnRight = ConcordNative.boolControlSide(path) == 2
    Column(modifier) {
        when (ConcordNative.boolFlavor(path)) {
            1 -> Row(modifier = if (controlOnRight) Modifier.fillMaxWidth() else Modifier, verticalAlignment = Alignment.CenterVertically) {
                if (controlOnRight) {
                    if (label.isNotEmpty()) RequiredLabel(path, label)
                    Spacer(Modifier.weight(1f))
                    Switch(checked = state == 1, enabled = enabled, onCheckedChange = { ConcordNative.setBool(path, it); refresh() })
                } else {
                    Switch(checked = state == 1, enabled = enabled, onCheckedChange = { ConcordNative.setBool(path, it); refresh() })
                    if (label.isNotEmpty()) { Spacer(Modifier.width(8.dp)); RequiredLabel(path, label) }
                }
                if (state < 0) {
                    Spacer(Modifier.width(8.dp))
                    Text("Undecided", fontStyle = FontStyle.Italic)
                }
            }
            2 -> Row(modifier = if (controlOnRight) Modifier.fillMaxWidth() else Modifier, verticalAlignment = Alignment.CenterVertically) {
                if (controlOnRight) {
                    if (label.isNotEmpty()) RequiredLabel(path, label)
                    Spacer(Modifier.weight(1f))
                }
                TriStateCheckbox(
                    state = when (state) { 1 -> androidx.compose.ui.state.ToggleableState.On; 0 -> androidx.compose.ui.state.ToggleableState.Off; else -> androidx.compose.ui.state.ToggleableState.Indeterminate },
                    enabled = enabled,
                    onClick = { ConcordNative.setBool(path, state != 1); refresh() }
                )
                if (!controlOnRight && label.isNotEmpty()) { Spacer(Modifier.width(8.dp)); RequiredLabel(path, label) }
            }
            3 -> Column {
                if (label.isNotEmpty()) RequiredLabel(path, label)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    RadioButton(selected = state == 1, enabled = enabled, onClick = { ConcordNative.setBool(path, true); refresh() })
                    Text(ConcordNative.boolTrueName(path))
                    Spacer(Modifier.width(12.dp))
                    RadioButton(selected = state == 0, enabled = enabled, onClick = { ConcordNative.setBool(path, false); refresh() })
                    Text(ConcordNative.boolFalseName(path))
                }
            }
        }
        ConcordMetadata(path)
    }
}

@Composable
private fun ConcordTextInput(path: String, modifier: Modifier, refresh: () -> Unit) {
    val enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path)
    val label = ConcordNative.textLabel(path)
    val placeholder = ConcordNative.textPlaceholder(path)
    val error = ConcordNative.errorText(path)
    val textColor = concordColor(path, 4)
    val fieldColors = if (textColor != null) OutlinedTextFieldDefaults.colors(
        focusedTextColor = textColor,
        unfocusedTextColor = textColor,
        disabledTextColor = textColor.copy(alpha = 0.5f)
    ) else OutlinedTextFieldDefaults.colors()
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(2.dp)) {
        OutlinedTextField(
            value = ConcordNative.textValue(path), onValueChange = { ConcordNative.setText(path, it); refresh() },
            modifier = Modifier.fillMaxWidth(), enabled = enabled, singleLine = true, isError = error.isNotEmpty(), colors = fieldColors,
            label = if (label.isNotEmpty()) ({ RequiredLabel(path, label) }) else null,
            placeholder = if (placeholder.isNotEmpty()) ({ Text(placeholder) }) else null,
            visualTransformation = if (ConcordNative.textFlavor(path) == 2) PasswordVisualTransformation() else VisualTransformation.None
        )
        ConcordMetadata(path)
    }
}

@Composable
private fun ConcordIntInput(path: String, modifier: Modifier, refresh: () -> Unit) {
    val enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path)
    val flavor = ConcordNative.intFlavor(path)
    val label = ConcordNative.intLabel(path)
    val value = if (ConcordNative.intHasValue(path)) ConcordNative.intValue(path) else null
    val lower = ConcordNative.intRangeLower(path)
    val upper = ConcordNative.intRangeUpper(path)
    val step = ConcordNative.intStep(path).coerceAtLeast(1L)
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        if (flavor == 1 || flavor == 4) OutlinedTextField(
            value = value?.toString() ?: "",
            onValueChange = { text -> if (text.isEmpty()) ConcordNative.clearInt(path) else text.toLongOrNull()?.let { ConcordNative.setInt(path, it) }; refresh() },
            modifier = Modifier.fillMaxWidth(), enabled = enabled, singleLine = true,
            label = if (label.isNotEmpty()) ({ RequiredLabel(path, label) }) else null,
            placeholder = if (ConcordNative.intPlaceholder(path).isNotEmpty()) ({ Text(ConcordNative.intPlaceholder(path)) }) else null,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
        )
        if (flavor == 3 || flavor == 4) Slider(
            value = (value ?: lower).toFloat(),
            onValueChange = { raw ->
                val snapped = lower + round((raw.toDouble() - lower.toDouble()) / step.toDouble()).toLong() * step
                ConcordNative.setInt(path, snapped.coerceIn(lower, upper)); refresh()
            },
            enabled = enabled, valueRange = lower.toFloat()..upper.toFloat()
        )
        if (flavor == 2 || flavor == 4) NumericStepper(
            path, label, value?.toString() ?: "nil", enabled,
            { ConcordNative.setInt(path, ((value ?: lower) - step).coerceAtLeast(lower)); refresh() },
            { ConcordNative.setInt(path, ((value ?: lower) + step).coerceAtMost(upper)); refresh() }
        )
        ConcordMetadata(path)
    }
}

@Composable
private fun ConcordFloatInput(path: String, modifier: Modifier, refresh: () -> Unit) {
    val enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path)
    val flavor = ConcordNative.floatFlavor(path)
    val label = ConcordNative.floatLabel(path)
    val value = if (ConcordNative.floatHasValue(path)) ConcordNative.floatValue(path) else null
    val lower = ConcordNative.floatRangeLower(path)
    val upper = ConcordNative.floatRangeUpper(path)
    val step = ConcordNative.floatStep(path).coerceAtLeast(0.0000001)
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        if (flavor == 1 || flavor == 4) OutlinedTextField(
            value = value?.toString() ?: "",
            onValueChange = { text -> if (text.isEmpty()) ConcordNative.clearFloat(path) else text.toDoubleOrNull()?.let { ConcordNative.setFloat(path, it) }; refresh() },
            modifier = Modifier.fillMaxWidth(), enabled = enabled, singleLine = true,
            label = if (label.isNotEmpty()) ({ RequiredLabel(path, label) }) else null,
            placeholder = if (ConcordNative.floatPlaceholder(path).isNotEmpty()) ({ Text(ConcordNative.floatPlaceholder(path)) }) else null,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal)
        )
        if (flavor == 3 || flavor == 4) Slider(
            value = (value ?: lower).toFloat(),
            onValueChange = { raw ->
                val snapped = lower + round((raw.toDouble() - lower) / step) * step
                ConcordNative.setFloat(path, snapped.coerceIn(lower, upper)); refresh()
            },
            enabled = enabled, valueRange = lower.toFloat()..upper.toFloat()
        )
        if (flavor == 2 || flavor == 4) NumericStepper(
            path, label, value?.toString() ?: "nil", enabled,
            { ConcordNative.setFloat(path, ((value ?: lower) - step).coerceAtLeast(lower)); refresh() },
            { ConcordNative.setFloat(path, ((value ?: lower) + step).coerceAtMost(upper)); refresh() }
        )
        ConcordMetadata(path)
    }
}

@Composable
private fun NumericStepper(path: String, label: String, value: String, enabled: Boolean, decrement: () -> Unit, increment: () -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(modifier = Modifier.weight(1f)) { RequiredLabel(path, if (label.isEmpty()) value else "$label: $value") }
        OutlinedButton(onClick = decrement, enabled = enabled) { Text("−") }
        Spacer(Modifier.width(6.dp))
        OutlinedButton(onClick = increment, enabled = enabled) { Text("+") }
    }
}

@Composable
private fun ConcordDateTimeInput(path: String, modifier: Modifier, type: Int, refresh: () -> Unit) {
    val context = LocalContext.current
    val enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path)
    val hasValue = ConcordNative.dateHasValue(path)
    val date = if (hasValue) Date((ConcordNative.dateValue(path) * 1000.0).toLong()) else Date()
    val label = ConcordNative.dateLabel(path)
    val flavor = ConcordNative.dateFlavor(path)
    val minimum = ConcordNative.dateMinimum(path).takeUnless { it.isNaN() }
    val maximum = ConcordNative.dateMaximum(path).takeUnless { it.isNaN() }
    val display = when (type) {
        11 -> DateFormat.getDateInstance().format(date)
        12 -> DateFormat.getTimeInstance(DateFormat.SHORT).format(date)
        else -> DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(date)
    }
    val calendar = Calendar.getInstance().apply { time = date }

    fun setCalendarValue() {
        val seconds = calendar.timeInMillis / 1000.0
        val bounded = when {
            minimum != null && seconds < minimum -> minimum
            maximum != null && seconds > maximum -> maximum
            else -> seconds
        }
        ConcordNative.setDateValue(path, bounded)
        refresh()
    }
    fun showDatePicker(after: (() -> Unit)? = null) {
        val dialog = DatePickerDialog(context, { _, year, month, day ->
            calendar.set(Calendar.YEAR, year); calendar.set(Calendar.MONTH, month); calendar.set(Calendar.DAY_OF_MONTH, day)
            setCalendarValue(); after?.invoke()
        }, calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), calendar.get(Calendar.DAY_OF_MONTH))
        minimum?.let { dialog.datePicker.minDate = (it * 1000.0).toLong() }
        maximum?.let { dialog.datePicker.maxDate = (it * 1000.0).toLong() }
        dialog.show()
    }
    fun showTimePicker() {
        TimePickerDialog(context, { _, hour, minute ->
            calendar.set(Calendar.HOUR_OF_DAY, hour); calendar.set(Calendar.MINUTE, minute); setCalendarValue()
        }, calendar.get(Calendar.HOUR_OF_DAY), calendar.get(Calendar.MINUTE), android.text.format.DateFormat.is24HourFormat(context)).show()
    }

    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        if (label.isNotEmpty()) RequiredLabel(path, label)
        if (!enabled) Text(if (hasValue) display else "—")
        else if (flavor == 2) {
            if (type == 11 || type == 13) {
                AndroidView(
                    factory = { android.widget.DatePicker(it) },
                    modifier = Modifier.fillMaxWidth(),
                    update = { picker ->
                        minimum?.let { picker.minDate = (it * 1000.0).toLong() }
                        maximum?.let { picker.maxDate = (it * 1000.0).toLong() }
                        picker.init(
                            calendar.get(Calendar.YEAR),
                            calendar.get(Calendar.MONTH),
                            calendar.get(Calendar.DAY_OF_MONTH)
                        ) { _, year, month, day ->
                            calendar.set(Calendar.YEAR, year)
                            calendar.set(Calendar.MONTH, month)
                            calendar.set(Calendar.DAY_OF_MONTH, day)
                            setCalendarValue()
                        }
                    }
                )
            }
            if (type == 12 || type == 13) {
                AndroidView(
                    factory = { android.widget.TimePicker(it) },
                    modifier = Modifier.fillMaxWidth(),
                    update = { picker ->
                        picker.setIs24HourView(android.text.format.DateFormat.is24HourFormat(context))
                        val hour = calendar.get(Calendar.HOUR_OF_DAY)
                        val minute = calendar.get(Calendar.MINUTE)
                        if (picker.hour != hour) picker.hour = hour
                        if (picker.minute != minute) picker.minute = minute
                        picker.setOnTimeChangedListener { _, selectedHour, selectedMinute ->
                            calendar.set(Calendar.HOUR_OF_DAY, selectedHour)
                            calendar.set(Calendar.MINUTE, selectedMinute)
                            setCalendarValue()
                        }
                    }
                )
            }
        }
        else OutlinedButton(onClick = {
            when (type) { 11 -> showDatePicker(); 12 -> showTimePicker(); else -> showDatePicker { showTimePicker() } }
        }) { Text(if (hasValue) display else "—") }
        ConcordMetadata(path)
    }
}

@Composable
private fun ConcordRaster(path: String, modifier: Modifier) {
    BoxWithConstraints(modifier = modifier) {
        val logicalWidth = ConcordNative.rasterWidth(path).coerceAtLeast(1.0)
        val logicalHeight = ConcordNative.rasterHeight(path).coerceAtLeast(1.0)
        val scaleX = maxWidth.value / logicalWidth.toFloat()
        val scaleY = maxHeight.value / logicalHeight.toFloat()

        repeat(ConcordNative.rasterImageCount(path, maxWidth.value.toDouble(), maxHeight.value.toDouble())) { index ->
            val x = ConcordNative.rasterImageX(path, index, maxWidth.value.toDouble(), maxHeight.value.toDouble()).toFloat() * scaleX
            val y = ConcordNative.rasterImageY(path, index, maxWidth.value.toDouble(), maxHeight.value.toDouble()).toFloat() * scaleY
            val width = ConcordNative.rasterImageWidth(path, index, maxWidth.value.toDouble(), maxHeight.value.toDouble()).toFloat() * scaleX
            val height = ConcordNative.rasterImageHeight(path, index, maxWidth.value.toDouble(), maxHeight.value.toDouble()).toFloat() * scaleY
            val contentScale = when (ConcordNative.rasterImageContentMode(path, index, maxWidth.value.toDouble(), maxHeight.value.toDouble())) {
                2 -> ContentScale.Crop
                3 -> ContentScale.FillBounds
                4 -> ContentScale.None
                else -> ContentScale.Fit
            }
            ConcordRasterImage(
                kind = ConcordNative.rasterImageKind(path, index, maxWidth.value.toDouble(), maxHeight.value.toDouble()),
                name = ConcordNative.rasterImageName(path, index, maxWidth.value.toDouble(), maxHeight.value.toDouble()),
                contentScale = contentScale,
                modifier = Modifier
                    .offset(x.dp, y.dp)
                    .size(width.dp, height.dp)
                    .zIndex(ConcordNative.rasterImageZOrder(path, index, maxWidth.value.toDouble(), maxHeight.value.toDouble()).toFloat())
            )
        }
    }
}

@Composable
private fun ConcordRasterImage(
    kind: Int,
    name: String,
    contentScale: ContentScale,
    modifier: Modifier
) {
    val context = LocalContext.current
    if (kind == 1) {
        val id = context.resources.getIdentifier(name, "drawable", context.packageName)
        if (id != 0) {
            Image(
                painter = painterResource(id),
                contentDescription = null,
                contentScale = contentScale,
                modifier = modifier
            )
            return
        }
        val candidates = listOf(
            name, "$name.png", "$name.jpg", "$name.jpeg", "$name.avif",
            "Image/$name.png", "Image/$name.jpg", "Image/$name.jpeg", "Image/$name.avif",
            "Resources/Image/$name.png", "Resources/Image/$name.jpg", "Resources/Image/$name.jpeg", "Resources/Image/$name.avif"
        )
        for (candidate in candidates) {
            val bitmap = runCatching {
                context.assets.open(candidate).use { BitmapFactory.decodeStream(it) }
            }.getOrNull()
            if (bitmap != null) {
                Image(
                    bitmap = bitmap.asImageBitmap(),
                    contentDescription = null,
                    contentScale = contentScale,
                    modifier = modifier
                )
                return
            }
        }
    } else if (kind == 2) {
        Icon(
            imageVector = concordIcon(name),
            contentDescription = null,
            modifier = modifier,
            tint = LocalContentColor.current
        )
    }
}

@Composable
private fun ConcordImage(path: String, modifier: Modifier) {
    val context = LocalContext.current
    val name = ConcordNative.imageName(path)
    if (ConcordNative.imageKind(path) == 2 && name == "app") {
        val drawable = runCatching {
            context.packageManager.getApplicationIcon(context.packageName)
        }.getOrNull()
        if (drawable != null) {
            val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
                drawable.bitmap
            } else {
                val width = drawable.intrinsicWidth.coerceAtLeast(1)
                val height = drawable.intrinsicHeight.coerceAtLeast(1)
                Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).also { output ->
                    val canvas = Canvas(output)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                }
            }
            Image(
                bitmap = bitmap.asImageBitmap(),
                contentDescription = ConcordNative.accessibilityText(path),
                modifier = modifier.size(64.dp)
            )
            return
        }
    }
    if (ConcordNative.imageKind(path) == 1) {
        val id = context.resources.getIdentifier(name, "drawable", context.packageName)
        if (id != 0) {
            Image(painter = painterResource(id), contentDescription = ConcordNative.accessibilityText(path), modifier = modifier)
            return
        }
        val candidates = listOf(
            name, "$name.png", "$name.jpg", "$name.jpeg", "$name.avif",
            "Image/$name.png", "Image/$name.jpg", "Image/$name.jpeg", "Image/$name.avif",
            "Resources/Image/$name.png", "Resources/Image/$name.jpg", "Resources/Image/$name.jpeg", "Resources/Image/$name.avif"
        )
        var bitmap: Bitmap? = null
        for (candidate in candidates) {
            bitmap = runCatching {
                context.assets.open(candidate).use { BitmapFactory.decodeStream(it) }
            }.getOrNull()
            if (bitmap != null) break
        }
        if (bitmap != null) {
            Image(
                bitmap = bitmap.asImageBitmap(),
                contentDescription = ConcordNative.accessibilityText(path),
                modifier = modifier
            )
        } else {
            Text("Missing image asset: $name", modifier = modifier)
        }
        return
    }
    Icon(imageVector = concordIcon(name), contentDescription = ConcordNative.accessibilityText(path), modifier = modifier, tint = concordColor(path, 1) ?: LocalContentColor.current)
}

@Composable
private fun ConcordProgress(path: String, modifier: Modifier) {
    val label = ConcordNative.progressLabel(path)
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        if (label.isNotEmpty()) Text(label)
        if (ConcordNative.progressFlavor(path) == 2) CircularProgressIndicator()
        else LinearProgressIndicator(progress = { ConcordNative.progressValue(path).toFloat() }, modifier = Modifier.fillMaxWidth())
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ConcordSelection(path: String, modifier: Modifier, refresh: () -> Unit) {
    val count = ConcordNative.selectionCount(path)
    val selected = ConcordNative.selectionIndex(path)
    val items = (0 until count).map { ConcordNative.selectionItemText(path, it) }
    val enabled = ConcordNative.isEnabled(path) && !ConcordNative.isReadOnly(path)
    Column(modifier) {
        val label = ConcordNative.selectionLabel(path)
        if (label.isNotEmpty()) RequiredLabel(path, label)
        when (ConcordNative.selectionFlavor(path)) {
            3 -> items.forEachIndexed { index, item ->
                Row(verticalAlignment = Alignment.CenterVertically) {
                    RadioButton(selected = selected == index, onClick = { ConcordNative.setSelectionIndex(path, index); refresh() }, enabled = enabled)
                    Text(item)
                }
            }
            4 -> SingleChoiceSegmentedButtonRow {
                items.forEachIndexed { index, item ->
                    SegmentedButton(
                        selected = selected == index,
                        onClick = { ConcordNative.setSelectionIndex(path, index); refresh() },
                        shape = SegmentedButtonDefaults.itemShape(index = index, count = items.size),
                        enabled = enabled
                    ) {
                        Text(item)
                    }
                }
            }
            5 -> Column(modifier = Modifier.fillMaxWidth()) {
                items.forEachIndexed { index, item ->
                    TextButton(
                        onClick = { ConcordNative.setSelectionIndex(path, index); refresh() },
                        modifier = Modifier.fillMaxWidth(),
                        enabled = enabled
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(item)
                            Spacer(Modifier.weight(1f))
                            if (selected == index) {
                                Icon(
                                    imageVector = Icons.Filled.Check,
                                    contentDescription = "Selected"
                                )
                            }
                        }
                    }
                    if (index + 1 < items.size) HorizontalDivider()
                }
            }
            else -> {
                var open by remember(path) { mutableStateOf(false) }
                Box {
                    OutlinedButton(onClick = { open = true }, enabled = enabled) { Text(if (selected in items.indices) items[selected] else "Select") }
                    DropdownMenu(expanded = open, onDismissRequest = { open = false }) {
                        items.forEachIndexed { index, item ->
                            DropdownMenuItem(text = { Text(item) }, onClick = { ConcordNative.setSelectionIndex(path, index); open = false; refresh() })
                        }
                    }
                }
            }
        }
        ConcordMetadata(path)
    }
}

@Composable
private fun ConcordExpander(path: String, modifier: Modifier, revision: Int, refresh: () -> Unit) {
    val expanded = ConcordNative.expanderExpanded(path)
    val checkbox = ConcordNative.expanderFlavor(path) == 2
    val onRight = ConcordNative.expanderOnRight(path)
    val toggle = { ConcordNative.toggleExpander(path); refresh() }
    val control: @Composable () -> Unit = {
        if (checkbox) Checkbox(checked = expanded, onCheckedChange = { toggle() })
        else IconButton(onClick = toggle) {
            Icon(imageVector = if (expanded) Icons.Filled.KeyboardArrowDown else Icons.Filled.KeyboardArrowRight, contentDescription = if (expanded) "Collapse" else "Expand")
        }
    }
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            if (!onRight) control()
            Text(
                ConcordNative.expanderLabel(path),
                fontWeight = if (ConcordNative.isBold(path)) FontWeight.Bold else FontWeight.Normal
            )
            if (onRight) { Spacer(Modifier.weight(1f)); control() }
        }
        if (expanded) repeat(ConcordNative.childCount(path)) { index -> ConcordElement(childPath(path, index), false, revision, refresh) }
    }
}

private fun childPath(path: String, index: Int): String = if (path.isEmpty()) index.toString() else "$path/$index"