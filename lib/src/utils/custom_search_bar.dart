import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'package:searchable_paginated_dropdown/src/utils/custom_inkwell.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    this.onChangeComplete,
    this.changeCompletionDelay = const Duration(milliseconds: 800),
    this.hintText,
    this.leadingIcon,
    this.isOutlined = false,
    this.focusNode,
    this.controller,
    this.style,
  });

  /// Klavyeden değer girme işlemi bittikten kaç milisaniye sonra on change complete fonksiyonunun tetikleneceğini belirler.
  final bool isOutlined;
  final Duration changeCompletionDelay;
  final FocusNode? focusNode;
  final String? hintText;
  final TextEditingController? controller;
  final TextStyle? style;

  /// Cancelable operation ile klavyeden değer girme işlemi kontrol edilir.
  /// Verilen delay içerisinde klavyeden yeni bir giriş olmaz ise bu fonksiyon tetiklenir.
  final void Function(String value)? onChangeComplete;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final myFocusNode = focusNode ?? FocusNode();

    return CustomInkwell(
      padding: EdgeInsets.zero,
      disableTabEffect: true,
      onTap: myFocusNode.requestFocus,
      child: /* isOutlined
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                  color: (style?.color ?? Colors.black).withOpacity(0.5),
                ),
              ),
              child: _SearchBarTextField(
                onChangeComplete: onChangeComplete,
                changeCompletionDelay: changeCompletionDelay,
                hintText: hintText,
                leadingIcon: leadingIcon,
                focusNode: focusNode,
                controller: controller,
                style: style,
              ),
            )
          : */
          _SearchBarTextField(
        onChangeComplete: onChangeComplete,
        changeCompletionDelay: changeCompletionDelay,
        hintText: hintText,
        leadingIcon: leadingIcon,
        focusNode: focusNode,
        controller: controller,
        style: style,
      ),
    );
  }
}

class _SearchBarTextField extends StatelessWidget {
  const _SearchBarTextField({
    this.onChangeComplete,
    this.changeCompletionDelay = const Duration(milliseconds: 800),
    this.hintText,
    this.leadingIcon,
    this.focusNode,
    this.controller,
    this.style,
  });

  final Duration changeCompletionDelay;
  final FocusNode? focusNode;
  final String? hintText;
  final TextEditingController? controller;
  final TextStyle? style;
  final void Function(String value)? onChangeComplete;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    // Future.delayed return Future<dynamic>
    //ignore: avoid-dynamic
    CancelableOperation<dynamic>? cancelableOperation;

    void startCancelableOperation() {
      cancelableOperation = CancelableOperation.fromFuture(
        Future.delayed(changeCompletionDelay),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                blurRadius: 4,
                offset: const Offset(0.0, 0.25))
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.send,
          onChanged: (value) async {
            await cancelableOperation?.cancel();
            startCancelableOperation();
            await cancelableOperation?.value.whenComplete(() {
              onChangeComplete?.call(value);
            });
          },
          // style: style,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            suffixIcon: Icon(
              Icons.search_rounded,
              size: 24,
              color: Color.fromRGBO(14, 65, 113, 1),
            ),
            hintStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: Color.fromRGBO(159, 183, 205, 1),
            ),
            hintText: hintText ?? 'Search ...',
            icon: leadingIcon,
          ),
          cursorColor: Color.fromRGBO(159, 183, 205, 1),
        ),
      ),
    );
  }
}
