import Foundation

/// Canonical Android renderer template used by generated ConcordUI applications.
/// Keep checked-in Android sample/showcase hosts synchronized with this renderer.
enum AndroidRendererTemplate {
    static func concordNative(packageName: String) -> String {
        #"""
package __PACKAGE__

object ConcordNative {
    init {
        System.loadLibrary("c++_shared")
        System.loadLibrary("ConcordUIAndroidApplication")
    }

    external fun setPlatformEnvironment()
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
"""#
        .replacingOccurrences(of: "__PACKAGE__", with: packageName)
    }

    static func mainActivity(packageName: String) -> String {
        #"""
package __PACKAGE__

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
                        .verticalScroll(rememberScrollState())
                    Box(modifier = hostModifier, contentAlignment = Alignment.TopStart) {
                        key(revision) {
                            ConcordElement("", false, revision, { revision += 1 })
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
"""#
        .replacingOccurrences(of: "__PACKAGE__", with: packageName)
    }

    static func swiftBridge(applicationType: String, packageName: String) -> String {
        let jniPrefix = packageName.replacingOccurrences(of: ".", with: "_")
        return #"""
import Android
import ConcordUI
import SharedApplication
import Foundation

final class ConcordAndroidPlatform: ConcordPlatform, ConcordVenuePlatformLifecycle {
    private(set) var currentPresentation: ConcordPresentation?
    private var previousPresentationsByVenueID: [String: ConcordPresentation] = [:]

    func displayPresentation(_ presentation: ConcordPresentation) {
        currentPresentation = presentation
    }

    func displayPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue) {
        if venue.config.kind == .secondary,
           currentPresentation !== presentation,
           let previous = currentPresentation,
           previousPresentationsByVenueID[venue.id] == nil {
            previousPresentationsByVenueID[venue.id] = previous
        }
        displayPresentation(presentation)
    }

    func refreshPresentation(_ presentation: ConcordPresentation) {
        currentPresentation = presentation
    }

    func refreshPresentation(_ presentation: ConcordPresentation, in venue: ConcordVenue) {
        refreshPresentation(presentation)
    }

    func closeVenue(_ venue: ConcordVenue) {
        restorePreviousPresentation(for: venue, discardIfNotVisible: false)
    }

    func dismissVenue(_ venue: ConcordVenue) {
        restorePreviousPresentation(for: venue, discardIfNotVisible: true)
    }

    private func restorePreviousPresentation(
        for venue: ConcordVenue,
        discardIfNotVisible: Bool
    ) {
        guard venue.config.kind == .secondary else { return }

        guard let venuePresentation = venue.currentPresentation,
              currentPresentation === venuePresentation else {
            if discardIfNotVisible {
                previousPresentationsByVenueID.removeValue(forKey: venue.id)
            }
            return
        }

        if let previous = previousPresentationsByVenueID.removeValue(forKey: venue.id) {
            displayPresentation(previous)
        } else if let mainPresentation = venue.application?.mainVenue.currentPresentation {
            displayPresentation(mainPresentation)
        }
    }

    func element(at path: String) -> ConcordElement? {
        guard var element = currentPresentation?.root else { return nil }
        guard !path.isEmpty else { return element }
        for component in path.split(separator: "/") {
            guard let index = Int(component), let container = element as? ConcordContainer,
                  container.elements.indices.contains(index) else { return nil }
            element = container.elements[index]
        }
        return element
    }
}

nonisolated(unsafe) private var androidPlatform: ConcordAndroidPlatform?
nonisolated(unsafe) private var androidApplication: __APPLICATION_TYPE__?

private func swiftString(_ value: jstring, environment: UnsafeMutablePointer<JNIEnv?>) -> String {
    guard let chars = environment.pointee!.pointee.GetStringUTFChars(environment, value, nil) else { return "" }
    defer { environment.pointee!.pointee.ReleaseStringUTFChars(environment, value, chars) }
    return String(cString: chars)
}
private func javaString(_ value: String, environment: UnsafeMutablePointer<JNIEnv?>) -> jstring {
    value.withCString { environment.pointee!.pointee.NewStringUTF(environment, $0)! }
}
private func element(_ path: jstring, environment: UnsafeMutablePointer<JNIEnv?>) -> ConcordElement? {
    androidPlatform?.element(at: swiftString(path, environment: environment))
}
private func color(_ value: ConcordElement?, role: jint) -> ConcordColor? {
    guard let value else { return nil }
    switch role { case 1: return value.resolvedForegroundColor; case 2: return value.resolvedBackgroundColor; case 3: return value.resolvedFrameColor; case 4: return value.resolvedTextColor; default: return nil }
}
private func explicitColor(_ value: ConcordElement?, role: jint) -> ConcordColor? {
    guard let value else { return nil }
    switch role { case 1: return value.foregroundColor; case 2: return value.backgroundColor; case 3: return value.frameColor; case 4: return value.textColor; default: return nil }
}
private func colorString(_ color: ConcordColor?) -> String {
    guard let color else { return "" }
    switch color { case .semantic(let semantic): return "semantic:\(semantic.rawValue)"; case .rgba(let r, let g, let b, let a): return "rgba:\(r),\(g),\(b),\(a)" }
}

@_cdecl("Java___JNI_PREFIX___ConcordNative_start")
public func concordAndroidStart(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject) {
    let platform = ConcordAndroidPlatform()
    let application = __APPLICATION_TYPE__(platform: platform)
    androidPlatform = platform
    androidApplication = application
    application.startApplication()
}

@_cdecl("Java___JNI_PREFIX___ConcordNative_completeStandardAppStart")
public func concordAndroidCompleteStandardAppStart(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject) {
    androidApplication?.completeStandardAppStart()
}

@_cdecl("Java___JNI_PREFIX___ConcordNative_elementType")
public func concordAndroidElementType(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let value = element(path, environment: environment) else { return 0 }
    if value is ConcordLabel { return 1 }; if value is ConcordButton { return 2 }; if value is ConcordVStack { return 3 }; if value is ConcordHStack { return 4 }
    if value is ConcordSpacer { return 5 }; if value is ConcordDivider { return 6 }; if value is ConcordBoolElement { return 7 }; if value is ConcordTextElement { return 8 }
    if value is ConcordIntElement { return 9 }; if value is ConcordFloatElement { return 10 }; if value is ConcordDateElement { return 11 }; if value is ConcordTimeElement { return 12 }
    if value is ConcordDateTimeElement { return 13 }; if value is ConcordImageElement { return 14 }; if value is ConcordProgressElement { return 15 }; if value is any ConcordSelectionPresenting { return 16 }
    if value is ConcordLine { return 17 }; if value is ConcordExpander { return 18 }; if value is ConcordABStack { return 19 }; if value is ConcordWorkStack { return 20 }; if value is ConcordRasterElement { return 21 }; if value is ConcordTitleActionElement { return 22 }; if value is ConcordActionGroupButton { return 23 }; return 0
}

@_cdecl("Java___JNI_PREFIX___ConcordNative_elementText") public func concordAndroidElementText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    let value: String
    if let label = element(path, environment: environment) as? ConcordLabel { value = label.label.map { "\($0): \(label.text)" } ?? label.text }
    else if let button = element(path, environment: environment) as? ConcordButton { value = button.title }
    else { value = "" }
    return javaString(value, environment: environment)
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_buttonFlavor") public func concordAndroidButtonFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let flavor = (element(path, environment: environment) as? ConcordButton)?.flavor else { return 0 }
    switch flavor { case .text: return 1; case .roundedRectangle: return 2; case .icon: return 3; case .textIcon: return 4 }
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_buttonRole") public func concordAndroidButtonRole(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let role = (element(path, environment: environment) as? ConcordButton)?.role else { return 0 }
    switch role { case .normal: return 1; case .defaultAction: return 2; case .cancel: return 3; case .destructive: return 4 }
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_buttonIcon") public func concordAndroidButtonIcon(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    javaString((element(path, environment: environment) as? ConcordButton)?.icon?.rawValue ?? "", environment: environment)
}

@_cdecl("Java___JNI_PREFIX___ConcordNative_titleActionFlavor")
public func concordAndroidTitleActionFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let flavor = (element(path, environment: environment) as? ConcordTitleActionElement)?.flavor else { return 0 }
    switch flavor { case .vlist: return 1; case .stack: return 2; case .popup: return 3 }
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_titleActionLabel")
public func concordAndroidTitleActionLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    javaString((element(path, environment: environment) as? ConcordTitleActionElement)?.label ?? "", environment: environment)
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_titleActionImageKind")
public func concordAndroidTitleActionImageKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let image = (element(path, environment: environment) as? ConcordTitleActionElement)?.image else { return 0 }
    switch image { case .asset: return 1; case .icon: return 2 }
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_titleActionImageName")
public func concordAndroidTitleActionImageName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    guard let image = (element(path, environment: environment) as? ConcordTitleActionElement)?.image else {
        return javaString("", environment: environment)
    }
    switch image {
    case .asset(let name): return javaString(name, environment: environment)
    case .icon(let icon): return javaString(icon.rawValue, environment: environment)
    }
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_titleActionCount")
public func concordAndroidTitleActionCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    jint((element(path, environment: environment) as? ConcordTitleActionElement)?.actionCount ?? 0)
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_titleActionTitle")
public func concordAndroidTitleActionTitle(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) -> jstring {
    javaString((element(path, environment: environment) as? ConcordTitleActionElement)?.actionTitle(at: Int(index)) ?? "", environment: environment)
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_activateTitleAction")
public func concordAndroidActivateTitleAction(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) {
    (element(path, environment: environment) as? ConcordTitleActionElement)?.activateAction(at: Int(index))
}

@_cdecl("Java___JNI_PREFIX___ConcordNative_actionGroupTitle")
public func concordAndroidActionGroupTitle(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    let title = (element(path, environment: environment) as? ConcordActionGroupButton)?
        .resolvedTitle() ?? ""
    return javaString(title, environment: environment)
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_actionGroupImageKind")
public func concordAndroidActionGroupImageKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    guard let image = (element(path, environment: environment) as? ConcordActionGroupButton)?.image else { return 0 }
    switch image { case .asset: return 1; case .icon: return 2 }
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_actionGroupImageName")
public func concordAndroidActionGroupImageName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring {
    guard let image = (element(path, environment: environment) as? ConcordActionGroupButton)?.image else {
        return javaString("", environment: environment)
    }
    switch image {
    case .asset(let name): return javaString(name, environment: environment)
    case .icon(let icon): return javaString(icon.rawValue, environment: environment)
    }
}

@_cdecl("Java___JNI_PREFIX___ConcordNative_actionGroupCount")
public func concordAndroidActionGroupCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint {
    jint((element(path, environment: environment) as? ConcordActionGroupButton)?
        .resolvedActionGroup()?.actions.count ?? 0)
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_actionGroupItemTitle")
public func concordAndroidActionGroupItemTitle(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) -> jstring {
    guard let actions = (element(path, environment: environment) as? ConcordActionGroupButton)?
        .resolvedActionGroup()?.actions,
        actions.indices.contains(Int(index)) else {
        return javaString("", environment: environment)
    }
    return javaString(actions[Int(index)].title, environment: environment)
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_activateActionGroupItem")
public func concordAndroidActivateActionGroupItem(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) {
    guard let actions = (element(path, environment: environment) as? ConcordActionGroupButton)?
        .resolvedActionGroup()?.actions,
        actions.indices.contains(Int(index)) else { return }
    actions[Int(index)].invoke()
}

@_cdecl("Java___JNI_PREFIX___ConcordNative_childCount") public func concordAndroidChildCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { jint((element(path, environment: environment) as? ConcordContainer)?.elements.count ?? 0) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_containerEdge") public func concordAndroidContainerEdge(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordContainer)?.edge ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_containerSpacing") public func concordAndroidContainerSpacing(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordContainer)?.spacing ?? ConcordContainer.defaultSpacing }
@_cdecl("Java___JNI_PREFIX___ConcordNative_workBottomHeight") public func concordAndroidWorkBottomHeight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordWorkStack)?.bottomHeight ?? ConcordWorkStack.defaultBottomHeight }
@_cdecl("Java___JNI_PREFIX___ConcordNative_justification") public func concordAndroidJustification(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment)?.horizontalJustification else { return 0 }; switch value { case .left: return 1; case .center: return 2; case .right: return 3 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_isVisible") public func concordAndroidIsVisible(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { element(path, environment: environment)?.isVisible == true ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_isEnabled") public func concordAndroidIsEnabled(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { element(path, environment: environment)?.isEnabled == true ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_isReadOnly") public func concordAndroidIsReadOnly(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { element(path, environment: environment)?.isReadOnly == true ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_isRequired") public func concordAndroidIsRequired(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { element(path, environment: environment)?.isRequired == true ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_validationState") public func concordAndroidValidationState(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) as? any ConcordValidatable else { return 0 }; switch value.validationState { case .unvalidated: return 0; case .valid: return 1; case .invalid: return 2 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_requiredIndicator") public func concordAndroidRequiredIndicator(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) else { return 0 }; switch value.requiredIndicator { case .none: return 0; case .redAsterisk: return 1; case .requiredText: return 2 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_invalidIndicator") public func concordAndroidInvalidIndicator(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) else { return 0 }; switch value.invalidIndicator { case .none: return 0; case .errorText: return 1; case .redBorder: return 2; case .redBorderAndErrorText: return 3 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_helpText") public func concordAndroidHelpText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(element(path, environment: environment)?.helpText ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_errorText") public func concordAndroidErrorText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(element(path, environment: environment)?.errorText ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_isBold") public func concordAndroidIsBold(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { ((element(path, environment: environment) as? ConcordLabel)?.textStyle?.isBold == true || (element(path, environment: environment) as? ConcordExpander)?.labelIsBold == true) ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_isItalic") public func concordAndroidIsItalic(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordLabel)?.textStyle?.isItalic == true ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_isUnderlined") public func concordAndroidIsUnderlined(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordLabel)?.textStyle?.isUnderlined == true ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_fontKind") public func concordAndroidFontKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) else { return 0 }; switch value.resolvedFont { case .system: return 1; case .monospaced: return 2 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_fontSize") public func concordAndroidFontSize(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { element(path, environment: environment)?.resolvedFontSize ?? 17 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_colorValue") public func concordAndroidColorValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, role: jint) -> jstring { javaString(colorString(color(element(path, environment: environment), role: role)), environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_explicitColorValue") public func concordAndroidExplicitColorValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, role: jint) -> jstring { javaString(colorString(explicitColor(element(path, environment: environment), role: role)), environment: environment) }

private func sizeCode(_ rule: ConcordSizeRule?) -> jint { guard let rule else { return 0 }; switch rule { case .content: return 1; case .fixed: return 2; case .fill: return 3 } }
private func fixedSize(_ rule: ConcordSizeRule?) -> Double { if case .fixed(let value) = rule { return value }; return 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_widthRule") public func concordAndroidWidthRule(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { sizeCode(element(path, environment: environment)?.structure?.width) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_heightRule") public func concordAndroidHeightRule(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { sizeCode(element(path, environment: environment)?.structure?.height) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_fixedWidth") public func concordAndroidFixedWidth(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { fixedSize(element(path, environment: environment)?.structure?.width) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_fixedHeight") public func concordAndroidFixedHeight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { fixedSize(element(path, environment: environment)?.structure?.height) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_boxWidth") public func concordAndroidBoxWidth(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { element(path, environment: environment)?.boxStyle?.width ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_boxRadius") public func concordAndroidBoxRadius(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { element(path, environment: environment)?.boxStyle?.cornerRadius ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_boxPadding") public func concordAndroidBoxPadding(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { element(path, environment: environment)?.boxStyle?.padding ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_accessibilityText") public func concordAndroidAccessibilityText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(element(path, environment: environment)?.accessibilityText ?? "", environment: environment) }

@_cdecl("Java___JNI_PREFIX___ConcordNative_boolFlavor") public func concordAndroidBoolFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = (element(path, environment: environment) as? ConcordBoolElement)?.flavor else { return 0 }; switch value { case .toggle: return 1; case .checkbox: return 2; case .radio: return 3 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_boolControlSide") public func concordAndroidBoolControlSide(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = element(path, environment: environment) as? ConcordBoolElement, let onRight = value.isControlOnRight else { return 0 }; return onRight ? 2 : 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_boolState") public func concordAndroidBoolState(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = (element(path, environment: environment) as? ConcordBoolElement)?.value else { return -1 }; return value ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_boolLabel") public func concordAndroidBoolLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordBoolElement)?.label ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_boolTrueName") public func concordAndroidBoolTrueName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordBoolElement)?.trueName ?? "True", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_boolFalseName") public func concordAndroidBoolFalseName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordBoolElement)?.falseName ?? "False", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_setBool") public func concordAndroidSetBool(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jboolean) { (element(path, environment: environment) as? ConcordBoolElement)?.userChangedValue(to: value != 0) }

@_cdecl("Java___JNI_PREFIX___ConcordNative_textFlavor") public func concordAndroidTextFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let value = (element(path, environment: environment) as? ConcordTextElement)?.flavor else { return 0 }; switch value { case .normal: return 1; case .password: return 2 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_textLabel") public func concordAndroidTextLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordTextElement)?.label ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_textPlaceholder") public func concordAndroidTextPlaceholder(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordTextElement)?.placeholder ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_textValue") public func concordAndroidTextValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordTextElement)?.value ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_setText") public func concordAndroidSetText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jstring) { (element(path, environment: environment) as? ConcordTextElement)?.userChangedValue(to: swiftString(value, environment: environment)) }

private func numericFlavorCode(_ value: ConcordNumericFlavor?) -> jint { guard let value else { return 0 }; switch value { case .input: return 1; case .stepper: return 2; case .slider: return 3; case .combo: return 4 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intFlavor") public func concordAndroidIntFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { numericFlavorCode((element(path, environment: environment) as? ConcordIntElement)?.flavor) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intLabel") public func concordAndroidIntLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordIntElement)?.label ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intPlaceholder") public func concordAndroidIntPlaceholder(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordIntElement)?.placeholder ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intHasValue") public func concordAndroidIntHasValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordIntElement)?.value == nil ? 0 : 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intValue") public func concordAndroidIntValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jlong { jlong((element(path, environment: environment) as? ConcordIntElement)?.value ?? 0) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intHasRange") public func concordAndroidIntHasRange(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordIntElement)?.range == nil ? 0 : 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intRangeLower") public func concordAndroidIntRangeLower(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jlong { jlong((element(path, environment: environment) as? ConcordIntElement)?.effectiveRange.lowerBound ?? 0) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intRangeUpper") public func concordAndroidIntRangeUpper(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jlong { jlong((element(path, environment: environment) as? ConcordIntElement)?.effectiveRange.upperBound ?? 100) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_intStep") public func concordAndroidIntStep(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jlong { jlong((element(path, environment: environment) as? ConcordIntElement)?.step ?? 1) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_setInt") public func concordAndroidSetInt(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jlong) { (element(path, environment: environment) as? ConcordIntElement)?.userChangedValue(to: ConcordInt(value)) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_clearInt") public func concordAndroidClearInt(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { (element(path, environment: environment) as? ConcordIntElement)?.userChangedValue(to: nil) }

@_cdecl("Java___JNI_PREFIX___ConcordNative_floatFlavor") public func concordAndroidFloatFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { numericFlavorCode((element(path, environment: environment) as? ConcordFloatElement)?.flavor) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_floatLabel") public func concordAndroidFloatLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordFloatElement)?.label ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_floatPlaceholder") public func concordAndroidFloatPlaceholder(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordFloatElement)?.placeholder ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_floatHasValue") public func concordAndroidFloatHasValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordFloatElement)?.value == nil ? 0 : 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_floatValue") public func concordAndroidFloatValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordFloatElement)?.value ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_floatHasRange") public func concordAndroidFloatHasRange(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordFloatElement)?.range == nil ? 0 : 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_floatRangeLower") public func concordAndroidFloatRangeLower(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordFloatElement)?.effectiveRange.lowerBound ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_floatRangeUpper") public func concordAndroidFloatRangeUpper(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordFloatElement)?.effectiveRange.upperBound ?? 100 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_floatStep") public func concordAndroidFloatStep(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordFloatElement)?.step ?? 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_setFloat") public func concordAndroidSetFloat(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jdouble) { (element(path, environment: environment) as? ConcordFloatElement)?.userChangedValue(to: ConcordFloat(value)) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_clearFloat") public func concordAndroidClearFloat(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { (element(path, environment: environment) as? ConcordFloatElement)?.userChangedValue(to: nil) }

private func dateElement(_ value: ConcordElement?) -> (flavor: jint, label: String, value: Date?, minimum: Date?, maximum: Date?)? {
    if let e = value as? ConcordDateElement { return (e.flavor == .components ? 2 : 1, e.label, e.value, e.minimumDate, e.maximumDate) }
    if let e = value as? ConcordTimeElement { return (e.flavor == .components ? 2 : 1, e.label, e.value, e.minimumDate, e.maximumDate) }
    if let e = value as? ConcordDateTimeElement { return (e.flavor == .components ? 2 : 1, e.label, e.value, e.minimumDate, e.maximumDate) }
    return nil
}
private func setDateElement(_ value: ConcordElement?, date: Date?) { if let e = value as? ConcordDateElement { e.userChangedValue(to: date) } else if let e = value as? ConcordTimeElement { e.userChangedValue(to: date) } else if let e = value as? ConcordDateTimeElement { e.userChangedValue(to: date) } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_dateFlavor") public func concordAndroidDateFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { dateElement(element(path, environment: environment))?.flavor ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_dateLabel") public func concordAndroidDateLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(dateElement(element(path, environment: environment))?.label ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_dateHasValue") public func concordAndroidDateHasValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { dateElement(element(path, environment: environment))?.value == nil ? 0 : 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_dateValue") public func concordAndroidDateValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { dateElement(element(path, environment: environment))?.value?.timeIntervalSince1970 ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_dateMinimum") public func concordAndroidDateMinimum(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { dateElement(element(path, environment: environment))?.minimum?.timeIntervalSince1970 ?? Double.nan }
@_cdecl("Java___JNI_PREFIX___ConcordNative_dateMaximum") public func concordAndroidDateMaximum(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { dateElement(element(path, environment: environment))?.maximum?.timeIntervalSince1970 ?? Double.nan }
@_cdecl("Java___JNI_PREFIX___ConcordNative_setDateValue") public func concordAndroidSetDateValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, value: jdouble) { setDateElement(element(path, environment: environment), date: Date(timeIntervalSince1970: value)) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_clearDateValue") public func concordAndroidClearDateValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { setDateElement(element(path, environment: environment), date: nil) }

@_cdecl("Java___JNI_PREFIX___ConcordNative_imageKind") public func concordAndroidImageKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let image = element(path, environment: environment) as? ConcordImageElement else { return 0 }; switch image.source { case .asset: return 1; case .icon: return 2 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_imageName") public func concordAndroidImageName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { guard let image = element(path, environment: environment) as? ConcordImageElement else { return javaString("", environment: environment) }; let name: String; switch image.source { case .asset(let value): name = value; case .icon(let icon): name = icon.rawValue }; return javaString(name, environment: environment) }
private func rasterElement(_ value: ConcordElement?) -> ConcordRasterElement? { value as? ConcordRasterElement }
private func rasterCommands(_ value: ConcordElement?, _ width: jdouble, _ height: jdouble) -> [ConcordRasterImageCommand] {
    guard let raster = rasterElement(value), width > 0, height > 0 else { return [] }
    return raster.imageCommands(in: ConcordSize(width: width, height: height))
}
private func rasterCommand(_ value: ConcordElement?, _ index: jint, _ width: jdouble, _ height: jdouble) -> ConcordRasterImageCommand? {
    let commands = rasterCommands(value, width, height)
    guard index >= 0, Int(index) < commands.count else { return nil }
    return commands[Int(index)]
}
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterWidth") public func concordAndroidRasterWidth(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { rasterElement(element(path, environment: environment))?.coordinateSize.width ?? 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterHeight") public func concordAndroidRasterHeight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { rasterElement(element(path, environment: environment))?.coordinateSize.height ?? 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageCount") public func concordAndroidRasterImageCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, width: jdouble, height: jdouble) -> jint { jint(rasterCommands(element(path, environment: environment), width, height).count) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageKind") public func concordAndroidRasterImageKind(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jint { guard let command = rasterCommand(element(path, environment: environment), index, width, height) else { return 0 }; switch command.imageData { case .asset: return 1; case .icon: return 2 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageName") public func concordAndroidRasterImageName(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jstring { guard let command = rasterCommand(element(path, environment: environment), index, width, height) else { return javaString("", environment: environment) }; let name: String; switch command.imageData { case .asset(let value): name = value; case .icon(let icon): name = icon.rawValue }; return javaString(name, environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageX") public func concordAndroidRasterImageX(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jdouble { rasterCommand(element(path, environment: environment), index, width, height)?.rect.origin.x ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageY") public func concordAndroidRasterImageY(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jdouble { rasterCommand(element(path, environment: environment), index, width, height)?.rect.origin.y ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageWidth") public func concordAndroidRasterImageWidth(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jdouble { rasterCommand(element(path, environment: environment), index, width, height)?.rect.size.width ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageHeight") public func concordAndroidRasterImageHeight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jdouble { rasterCommand(element(path, environment: environment), index, width, height)?.rect.size.height ?? 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageZOrder") public func concordAndroidRasterImageZOrder(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jint { jint(rasterCommand(element(path, environment: environment), index, width, height)?.zOrder ?? 0) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_rasterImageContentMode") public func concordAndroidRasterImageContentMode(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint, width: jdouble, height: jdouble) -> jint { guard let mode = rasterCommand(element(path, environment: environment), index, width, height)?.contentMode else { return 1 }; switch mode { case .fit: return 1; case .fill: return 2; case .stretch: return 3; case .original: return 4 } }

@_cdecl("Java___JNI_PREFIX___ConcordNative_progressFlavor") public func concordAndroidProgressFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let progress = element(path, environment: environment) as? ConcordProgressElement else { return 0 }; return progress.flavor == .spinner ? 2 : 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_progressLabel") public func concordAndroidProgressLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordProgressElement)?.label ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_progressValue") public func concordAndroidProgressValue(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jdouble { (element(path, environment: environment) as? ConcordProgressElement)?.value ?? 0 }

private func selectionElement(_ value: ConcordElement?) -> (any ConcordSelectionPresenting)? { value as? any ConcordSelectionPresenting }
private func selectionFlavorCode(_ flavor: ConcordSelectionFlavor) -> jint { switch flavor { case .popup: return 1; case .spinner: return 2; case .radio: return 3; case .segmented: return 4; case .list: return 5 } }
@_cdecl("Java___JNI_PREFIX___ConcordNative_selectionFlavor") public func concordAndroidSelectionFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let selection = selectionElement(element(path, environment: environment)) else { return 0 }; return selectionFlavorCode(selection.flavor) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_selectionLabel") public func concordAndroidSelectionLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString(selectionElement(element(path, environment: environment))?.label ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_selectionCount") public func concordAndroidSelectionCount(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { jint(selectionElement(element(path, environment: environment))?.itemCount ?? 0) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_selectionIndex") public func concordAndroidSelectionIndex(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { jint(selectionElement(element(path, environment: environment))?.selectedIndex ?? -1) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_selectionItemText") public func concordAndroidSelectionItemText(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) -> jstring { guard let selection = selectionElement(element(path, environment: environment)) else { return javaString("", environment: environment) }; return javaString(selection.displayText(at: Int(index)), environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_setSelectionIndex") public func concordAndroidSetSelectionIndex(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring, index: jint) { selectionElement(element(path, environment: environment))?.userSelected(index: Int(index)) }

@_cdecl("Java___JNI_PREFIX___ConcordNative_expanderFlavor") public func concordAndroidExpanderFlavor(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jint { guard let expander = element(path, environment: environment) as? ConcordExpander else { return 0 }; return expander.flavor == .checkbox ? 2 : 1 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_expanderLabel") public func concordAndroidExpanderLabel(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jstring { javaString((element(path, environment: environment) as? ConcordExpander)?.label ?? "", environment: environment) }
@_cdecl("Java___JNI_PREFIX___ConcordNative_expanderExpanded") public func concordAndroidExpanderExpanded(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordExpander)?.isExpanded == true ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_expanderOnRight") public func concordAndroidExpanderOnRight(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) -> jboolean { (element(path, environment: environment) as? ConcordExpander)?.onRight == true ? 1 : 0 }
@_cdecl("Java___JNI_PREFIX___ConcordNative_toggleExpander") public func concordAndroidToggleExpander(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { (element(path, environment: environment) as? ConcordExpander)?.toggleExpanded() }

@_cdecl("Java___JNI_PREFIX___ConcordNative_activate") public func concordAndroidActivate(environment: UnsafeMutablePointer<JNIEnv?>, receiver: jobject, path: jstring) { (element(path, environment: environment) as? ConcordButton)?.activate() }
"""#
        .replacingOccurrences(of: "__APPLICATION_TYPE__", with: applicationType)
        .replacingOccurrences(of: "__JNI_PREFIX__", with: jniPrefix)
    }
}
