import '../../imports/core_imports.dart';
import '../../imports/imports.dart';

class AppDropDownField<T> extends StatelessWidget {
  const AppDropDownField({
    super.key,
    required this.items,
    required this.value,
    this.label,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofocus = false,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final String? hint;
  final String? label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      initialSelection: value,
      onSelected: onChanged,
      enabled: enabled,
      expandedInsets: EdgeInsets.zero,
      requestFocusOnTap: false,
      label: label != null ? Text(label!) : null,
      hintText: hint,
      leadingIcon: prefixIcon,
      trailingIcon: suffixIcon,
      menuStyle: MenuStyle(
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppBorders.card),
        ),
        surfaceTintColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? context.colors.primary
              : context.colors.surfaceContainerHigh,
        ),
        shadowColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? context.colors.primary
              : context.colors.shadow,
        ),
        elevation: const WidgetStatePropertyAll(3),
      ),
      textStyle: context.textTheme.bodyLarge?.copyWith(
        color: context.colors.onSurface,
      ),
      dropdownMenuEntries: items.map((T item) {
        return DropdownMenuEntry<T>(value: item, label: item.toString());
      }).toList(),
    );
  }
}
