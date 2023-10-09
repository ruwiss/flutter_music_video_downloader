import 'package:flutter/material.dart';
import 'package:melotune/utils/colors.dart';

Widget loadingIndicator() => const SizedBox(
      width: 25,
      height: 25,
      child: CircularProgressIndicator(
        color: KColors.appPrimary,
      ),
    );
