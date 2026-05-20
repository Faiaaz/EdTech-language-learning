// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

class _Stroke {
  const _Stroke(this.points);
  final List<Offset> points;
}

class HiraganaChar {
  const HiraganaChar({
    required this.kana,
    required this.romaji,
    required this.bn,
    required this.strokes,
  });
  final String kana;
  final String romaji;
  final String bn;
  final List<_Stroke> strokes;
}

// Stroke coordinates sampled from KanjiVG (CC-BY-SA 3.0), normalized 0-100.
// Source: https://kanjivg.tagaini.net/  Repo: https://github.com/KanjiVG/kanjivg
const List<HiraganaChar> kHiraganaSet = [
  HiraganaChar(kana: 'あ', romaji: 'a', bn: 'আ', strokes: [
    _Stroke([Offset(28.4, 30.3), Offset(30.7, 31.5), Offset(33.9, 31.9), Offset(36.6, 31.7), Offset(39.5, 31.5), Offset(42.4, 31.1), Offset(45.4, 30.7), Offset(48.5, 30.3), Offset(51.6, 29.7), Offset(54.6, 29.2), Offset(57.6, 28.6), Offset(60.4, 28.0), Offset(63.3, 27.5), Offset(66.4, 27.5)]),
    _Stroke([Offset(45.7, 16.2), Offset(46.9, 21.0), Offset(45.9, 26.0), Offset(44.9, 31.2), Offset(44.1, 36.5), Offset(43.3, 41.9), Offset(42.8, 47.4), Offset(42.3, 52.7), Offset(42.1, 58.0), Offset(42.0, 63.0), Offset(42.1, 67.8), Offset(42.5, 73.2), Offset(43.7, 78.7), Offset(45.3, 82.7)]),
    _Stroke([Offset(60.2, 40.5), Offset(57.8, 52.8), Offset(51.3, 64.0), Offset(41.5, 75.2), Offset(29.1, 81.7), Offset(22.5, 70.5), Offset(26.8, 60.3), Offset(38.0, 51.6), Offset(53.8, 46.4), Offset(68.3, 47.5), Offset(78.8, 55.3), Offset(80.8, 68.1), Offset(74.7, 79.3), Offset(61.0, 86.3)]),
  ]),
  HiraganaChar(kana: 'い', romaji: 'i', bn: 'ই', strokes: [
    _Stroke([Offset(19.7, 27.2), Offset(21.8, 31.4), Offset(21.3, 36.7), Offset(20.7, 42.5), Offset(20.5, 47.8), Offset(20.7, 52.7), Offset(21.4, 57.3), Offset(22.5, 61.4), Offset(24.1, 65.2), Offset(26.2, 68.7), Offset(28.9, 71.9), Offset(32.9, 75.1), Offset(34.7, 73.3), Offset(35.4, 67.3)]),
    _Stroke([Offset(66.9, 33.5), Offset(68.9, 35.2), Offset(70.8, 37.1), Offset(72.7, 39.0), Offset(74.5, 41.1), Offset(76.1, 43.2), Offset(77.7, 45.5), Offset(79.1, 47.8), Offset(80.4, 50.3), Offset(81.5, 52.9), Offset(82.4, 55.6), Offset(83.1, 58.4), Offset(83.6, 61.4), Offset(83.8, 64.5)]),
  ]),
  HiraganaChar(kana: 'う', romaji: 'u', bn: 'উ', strokes: [
    _Stroke([Offset(38.5, 14.2), Offset(40.9, 15.1), Offset(43.1, 15.7), Offset(45.0, 16.3), Offset(46.8, 16.6), Offset(48.5, 16.9), Offset(50.0, 17.0), Offset(52.6, 17.0), Offset(54.7, 17.2), Offset(55.7, 17.6), Offset(55.8, 18.3), Offset(54.9, 19.2), Offset(52.9, 20.4), Offset(50.0, 22.0)]),
    _Stroke([Offset(30.3, 38.9), Offset(36.6, 40.5), Offset(43.1, 37.8), Offset(50.4, 34.6), Offset(56.7, 33.9), Offset(61.1, 36.7), Offset(63.9, 43.5), Offset(64.4, 52.7), Offset(63.4, 59.3), Offset(61.3, 65.7), Offset(58.2, 71.8), Offset(53.9, 77.6), Offset(48.5, 83.1), Offset(42.1, 88.1)]),
  ]),
  HiraganaChar(kana: 'え', romaji: 'e', bn: 'এ', strokes: [
    _Stroke([Offset(37.2, 12.2), Offset(39.5, 13.0), Offset(41.6, 13.6), Offset(43.6, 14.1), Offset(45.6, 14.5), Offset(47.4, 14.8), Offset(49.2, 14.9), Offset(51.6, 14.9), Offset(54.1, 15.1), Offset(55.4, 15.5), Offset(55.6, 16.1), Offset(54.8, 17.0), Offset(52.8, 18.3), Offset(49.8, 20.0)]),
    _Stroke([Offset(29.8, 41.4), Offset(41.4, 39.8), Offset(55.2, 33.3), Offset(58.9, 38.6), Offset(50.0, 48.9), Offset(40.7, 59.4), Offset(31.5, 69.6), Offset(22.5, 79.8), Offset(34.8, 69.0), Offset(43.7, 61.5), Offset(50.7, 64.5), Offset(52.5, 79.6), Offset(62.6, 84.6), Offset(77.1, 83.1)]),
  ]),
  HiraganaChar(kana: 'お', romaji: 'o', bn: 'ও', strokes: [
    _Stroke([Offset(21.0, 32.2), Offset(22.9, 33.4), Offset(25.3, 34.2), Offset(27.1, 34.1), Offset(29.0, 33.6), Offset(31.6, 33.0), Offset(34.7, 32.1), Offset(37.9, 31.3), Offset(40.9, 30.4), Offset(43.5, 29.7), Offset(45.3, 29.1), Offset(46.5, 28.7), Offset(48.9, 27.9), Offset(51.3, 27.1)]),
    _Stroke([Offset(38.1, 14.8), Offset(40.0, 28.9), Offset(38.8, 46.2), Offset(38.4, 63.4), Offset(39.0, 78.2), Offset(28.7, 79.6), Offset(19.9, 69.2), Offset(27.8, 60.4), Offset(43.8, 51.9), Offset(62.9, 48.7), Offset(79.3, 54.4), Offset(83.6, 65.8), Offset(76.7, 76.8), Offset(59.2, 83.7)]),
    _Stroke([Offset(67.0, 20.3), Offset(68.6, 21.1), Offset(70.0, 22.0), Offset(71.4, 22.9), Offset(72.6, 23.8), Offset(73.7, 24.7), Offset(74.7, 25.5), Offset(75.5, 26.4), Offset(76.2, 27.2), Offset(76.9, 28.1), Offset(77.7, 29.9), Offset(77.5, 31.1), Offset(76.7, 32.0), Offset(75.7, 32.4)]),
  ]),
  HiraganaChar(kana: 'か', romaji: 'ka', bn: 'কা', strokes: [
    _Stroke([Offset(22.6, 35.4), Offset(28.9, 36.8), Offset(40.5, 33.4), Offset(49.0, 32.3), Offset(54.2, 33.5), Offset(56.8, 37.0), Offset(57.5, 42.3), Offset(57.3, 49.6), Offset(56.4, 56.7), Offset(54.8, 63.3), Offset(50.9, 73.1), Offset(46.4, 79.9), Offset(42.7, 80.3), Offset(38.9, 76.5)]),
    _Stroke([Offset(44.5, 16.1), Offset(45.3, 21.0), Offset(43.6, 26.3), Offset(41.4, 32.1), Offset(38.8, 38.1), Offset(36.1, 44.1), Offset(33.5, 49.7), Offset(31.0, 54.8), Offset(29.0, 58.9), Offset(27.5, 61.7), Offset(26.2, 64.2), Offset(23.6, 69.1), Offset(20.9, 73.7), Offset(18.3, 77.8)]),
    _Stroke([Offset(71.0, 29.0), Offset(72.5, 30.5), Offset(74.0, 32.0), Offset(75.5, 33.7), Offset(76.8, 35.3), Offset(78.1, 37.0), Offset(79.3, 38.8), Offset(80.4, 40.5), Offset(81.4, 42.4), Offset(82.3, 44.2), Offset(83.1, 46.1), Offset(83.7, 48.0), Offset(84.3, 49.9), Offset(84.7, 51.8)]),
  ]),
  HiraganaChar(kana: 'き', romaji: 'ki', bn: 'কি', strokes: [
    _Stroke([Offset(28.0, 27.8), Offset(30.9, 28.5), Offset(33.3, 28.6), Offset(35.6, 28.2), Offset(38.3, 27.7), Offset(41.3, 27.1), Offset(44.5, 26.4), Offset(47.6, 25.7), Offset(50.6, 25.0), Offset(53.4, 24.3), Offset(55.7, 23.7), Offset(57.4, 23.1), Offset(60.0, 22.2), Offset(62.2, 21.1)]),
    _Stroke([Offset(33.3, 44.7), Offset(36.4, 45.5), Offset(39.0, 45.6), Offset(41.4, 45.2), Offset(44.3, 44.6), Offset(47.5, 43.9), Offset(50.9, 43.2), Offset(54.3, 42.3), Offset(57.5, 41.5), Offset(60.4, 40.8), Offset(62.9, 40.1), Offset(64.8, 39.5), Offset(67.5, 38.4), Offset(69.8, 37.2)]),
    _Stroke([Offset(38.5, 13.0), Offset(41.9, 17.0), Offset(44.0, 21.7), Offset(46.3, 26.5), Offset(49.0, 31.2), Offset(51.9, 36.0), Offset(55.0, 40.6), Offset(58.3, 45.1), Offset(61.6, 49.5), Offset(65.1, 53.6), Offset(69.5, 58.4), Offset(71.6, 61.4), Offset(69.1, 61.4), Offset(60.9, 58.6)]),
    _Stroke([Offset(31.0, 76.4), Offset(33.3, 78.3), Offset(35.8, 79.8), Offset(38.5, 81.1), Offset(41.2, 82.0), Offset(44.0, 82.7), Offset(46.9, 83.1), Offset(49.8, 83.3), Offset(52.7, 83.3), Offset(55.5, 83.2), Offset(58.3, 82.8), Offset(61.0, 82.3), Offset(63.5, 81.7), Offset(65.9, 81.0)]),
  ]),
  HiraganaChar(kana: 'く', romaji: 'ku', bn: 'কু', strokes: [
    _Stroke([Offset(55.7, 13.8), Offset(55.0, 20.2), Offset(50.6, 26.2), Offset(46.3, 32.0), Offset(42.2, 37.3), Offset(38.7, 41.6), Offset(35.1, 47.2), Offset(36.4, 52.5), Offset(40.0, 57.5), Offset(43.7, 63.1), Offset(47.5, 68.9), Offset(51.0, 74.7), Offset(54.1, 79.9), Offset(57.1, 86.0)]),
  ]),
  HiraganaChar(kana: 'け', romaji: 'ke', bn: 'কে', strokes: [
    _Stroke([Offset(22.6, 18.1), Offset(24.7, 22.8), Offset(23.7, 28.4), Offset(22.6, 33.8), Offset(21.7, 39.1), Offset(20.8, 44.3), Offset(20.2, 49.5), Offset(19.8, 54.6), Offset(19.8, 59.9), Offset(20.2, 65.5), Offset(21.3, 72.9), Offset(22.4, 72.5), Offset(23.9, 67.8), Offset(26.3, 61.7)]),
    _Stroke([Offset(49.2, 35.4), Offset(51.5, 36.5), Offset(53.8, 36.9), Offset(56.5, 36.7), Offset(59.4, 36.2), Offset(62.1, 35.8), Offset(64.7, 35.3), Offset(67.2, 34.8), Offset(69.5, 34.3), Offset(71.7, 33.8), Offset(73.7, 33.4), Offset(76.1, 32.7), Offset(78.7, 32.3), Offset(80.8, 32.1)]),
    _Stroke([Offset(65.8, 13.2), Offset(68.4, 18.1), Offset(68.4, 24.4), Offset(68.4, 30.3), Offset(68.5, 35.9), Offset(68.5, 41.4), Offset(68.5, 47.4), Offset(68.4, 54.5), Offset(68.0, 60.7), Offset(67.3, 66.2), Offset(66.0, 71.1), Offset(63.9, 75.7), Offset(61.0, 80.0), Offset(57.0, 84.3)]),
  ]),
  HiraganaChar(kana: 'こ', romaji: 'ko', bn: 'কো', strokes: [
    _Stroke([Offset(31.9, 24.5), Offset(34.8, 25.9), Offset(39.1, 25.6), Offset(42.8, 25.0), Offset(46.4, 24.5), Offset(50.0, 24.0), Offset(53.8, 23.7), Offset(57.8, 23.5), Offset(63.1, 23.8), Offset(65.2, 24.8), Offset(64.6, 26.2), Offset(61.9, 28.0), Offset(57.7, 29.9), Offset(52.6, 31.8)]),
    _Stroke([Offset(27.5, 62.5), Offset(28.6, 66.6), Offset(30.3, 70.0), Offset(32.7, 72.7), Offset(35.6, 74.8), Offset(39.0, 76.3), Offset(42.8, 77.4), Offset(47.0, 77.9), Offset(51.5, 78.1), Offset(56.2, 77.8), Offset(60.4, 77.4), Offset(64.4, 76.9), Offset(68.3, 76.2), Offset(72.1, 75.2)]),
  ]),
  HiraganaChar(kana: 'さ', romaji: 'sa', bn: 'সা', strokes: [
    _Stroke([Offset(24.8, 35.7), Offset(28.1, 36.7), Offset(31.8, 36.7), Offset(34.9, 36.2), Offset(38.4, 35.4), Offset(42.3, 34.4), Offset(46.4, 33.2), Offset(50.6, 31.9), Offset(54.5, 30.6), Offset(58.1, 29.4), Offset(61.1, 28.2), Offset(63.4, 27.2), Offset(66.5, 25.7), Offset(69.5, 23.9)]),
    _Stroke([Offset(38.1, 12.7), Offset(41.7, 16.5), Offset(43.8, 21.1), Offset(46.1, 25.7), Offset(48.6, 30.3), Offset(51.4, 34.7), Offset(54.5, 39.2), Offset(57.9, 43.5), Offset(61.4, 47.7), Offset(65.1, 51.8), Offset(69.6, 56.7), Offset(71.3, 60.0), Offset(68.6, 60.0), Offset(61.3, 56.5)]),
    _Stroke([Offset(32.3, 73.9), Offset(33.5, 76.2), Offset(35.0, 78.1), Offset(36.8, 79.8), Offset(39.0, 81.1), Offset(41.4, 82.1), Offset(44.1, 82.8), Offset(46.9, 83.2), Offset(50.0, 83.4), Offset(53.3, 83.3), Offset(56.7, 83.0), Offset(60.2, 82.5), Offset(63.9, 81.7), Offset(67.6, 80.7)]),
  ]),
  HiraganaChar(kana: 'し', romaji: 'shi', bn: 'শি', strokes: [
    _Stroke([Offset(35.9, 16.1), Offset(36.5, 23.9), Offset(35.3, 32.0), Offset(34.4, 40.0), Offset(33.9, 47.9), Offset(33.6, 55.7), Offset(33.6, 64.0), Offset(35.1, 72.5), Offset(38.4, 78.5), Offset(43.4, 82.3), Offset(49.7, 83.9), Offset(57.3, 83.5), Offset(65.9, 81.2), Offset(75.2, 77.2)]),
  ]),
  HiraganaChar(kana: 'す', romaji: 'su', bn: 'সু', strokes: [
    _Stroke([Offset(14.2, 34.1), Offset(18.6, 35.3), Offset(24.6, 34.6), Offset(30.6, 33.3), Offset(36.6, 32.3), Offset(42.6, 31.4), Offset(48.6, 30.6), Offset(54.3, 29.9), Offset(59.7, 29.3), Offset(64.5, 28.8), Offset(68.6, 28.3), Offset(74.4, 27.9), Offset(79.7, 27.9), Offset(85.0, 28.4)]),
    _Stroke([Offset(52.9, 12.3), Offset(55.4, 21.3), Offset(55.4, 32.9), Offset(55.4, 45.1), Offset(55.4, 54.0), Offset(52.3, 63.8), Offset(44.6, 65.1), Offset(41.1, 55.1), Offset(45.9, 47.9), Offset(53.6, 50.0), Offset(57.6, 62.4), Offset(55.5, 73.2), Offset(50.1, 81.7), Offset(42.9, 88.6)]),
  ]),
  HiraganaChar(kana: 'せ', romaji: 'se', bn: 'সে', strokes: [
    _Stroke([Offset(15.1, 45.8), Offset(19.5, 47.2), Offset(25.6, 46.5), Offset(32.2, 45.4), Offset(38.3, 44.3), Offset(44.0, 43.3), Offset(49.5, 42.4), Offset(54.8, 41.6), Offset(59.9, 40.8), Offset(64.8, 40.0), Offset(69.8, 39.3), Offset(75.7, 38.7), Offset(81.1, 38.5), Offset(86.3, 39.0)]),
    _Stroke([Offset(64.0, 16.3), Offset(66.3, 19.7), Offset(66.5, 24.7), Offset(66.5, 29.8), Offset(66.5, 34.3), Offset(66.5, 38.2), Offset(66.5, 41.7), Offset(66.4, 48.5), Offset(65.7, 55.8), Offset(64.4, 60.4), Offset(62.7, 62.6), Offset(60.5, 63.1), Offset(58.1, 62.3), Offset(55.6, 60.7)]),
    _Stroke([Offset(32.7, 24.1), Offset(35.2, 30.0), Offset(35.2, 37.1), Offset(35.2, 45.0), Offset(35.2, 52.5), Offset(35.2, 58.5), Offset(35.4, 64.8), Offset(37.2, 71.3), Offset(40.9, 75.6), Offset(46.6, 78.0), Offset(54.3, 78.6), Offset(61.7, 78.6), Offset(67.7, 78.2), Offset(74.4, 77.1)]),
  ]),
  HiraganaChar(kana: 'そ', romaji: 'so', bn: 'সো', strokes: [
    _Stroke([Offset(35.2, 20.2), Offset(52.7, 17.6), Offset(62.5, 21.0), Offset(47.5, 33.2), Offset(32.5, 44.1), Offset(24.1, 52.4), Offset(43.4, 47.9), Offset(61.3, 44.1), Offset(79.4, 41.8), Offset(64.9, 45.8), Offset(48.7, 55.8), Offset(42.8, 69.8), Offset(51.2, 81.6), Offset(71.6, 83.0)]),
  ]),
  HiraganaChar(kana: 'た', romaji: 'ta', bn: 'তা', strokes: [
    _Stroke([Offset(22.4, 32.5), Offset(24.7, 33.3), Offset(27.8, 33.5), Offset(30.2, 33.2), Offset(32.7, 32.8), Offset(35.3, 32.3), Offset(38.1, 31.8), Offset(41.0, 31.2), Offset(44.0, 30.6), Offset(47.0, 30.0), Offset(49.9, 29.4), Offset(52.7, 28.7), Offset(55.5, 27.9), Offset(58.0, 26.9)]),
    _Stroke([Offset(41.3, 15.5), Offset(41.5, 20.8), Offset(39.6, 26.8), Offset(37.8, 32.4), Offset(35.9, 37.8), Offset(34.0, 42.9), Offset(32.2, 47.9), Offset(30.4, 52.7), Offset(28.5, 57.5), Offset(26.7, 62.2), Offset(24.9, 66.8), Offset(23.1, 71.5), Offset(20.7, 77.2), Offset(18.8, 81.8)]),
    _Stroke([Offset(51.7, 48.9), Offset(56.0, 47.9), Offset(59.7, 47.2), Offset(62.9, 46.6), Offset(65.7, 46.2), Offset(68.2, 45.9), Offset(70.4, 45.8), Offset(72.5, 45.9), Offset(76.8, 46.4), Offset(79.2, 47.1), Offset(78.2, 47.7), Offset(75.4, 48.4), Offset(72.0, 49.3), Offset(69.5, 50.5)]),
    _Stroke([Offset(49.7, 75.5), Offset(50.7, 76.8), Offset(51.9, 78.0), Offset(53.3, 79.1), Offset(54.9, 79.9), Offset(56.8, 80.6), Offset(58.9, 81.1), Offset(61.2, 81.5), Offset(63.8, 81.7), Offset(66.7, 81.7), Offset(69.9, 81.6), Offset(73.4, 81.4), Offset(77.2, 81.1), Offset(81.3, 80.6)]),
  ]),
  HiraganaChar(kana: 'ち', romaji: 'chi', bn: 'চি', strokes: [
    _Stroke([Offset(22.5, 29.9), Offset(25.0, 30.8), Offset(28.2, 31.0), Offset(30.6, 30.6), Offset(33.2, 30.0), Offset(36.0, 29.4), Offset(39.1, 28.7), Offset(42.2, 28.0), Offset(45.4, 27.2), Offset(48.5, 26.5), Offset(51.5, 25.8), Offset(54.4, 25.1), Offset(57.3, 24.2), Offset(60.0, 23.3)]),
    _Stroke([Offset(41.9, 14.3), Offset(40.9, 25.7), Offset(38.9, 35.8), Offset(36.6, 46.0), Offset(32.9, 60.0), Offset(35.0, 60.8), Offset(45.8, 54.0), Offset(56.6, 50.6), Offset(67.3, 50.2), Offset(75.7, 56.3), Offset(76.7, 67.1), Offset(70.9, 75.5), Offset(61.1, 81.2), Offset(49.9, 84.5)]),
  ]),
  HiraganaChar(kana: 'つ', romaji: 'tsu', bn: 'তসু', strokes: [
    _Stroke([Offset(12.8, 41.1), Offset(23.2, 40.4), Offset(34.0, 36.3), Offset(43.8, 33.5), Offset(53.3, 31.9), Offset(63.3, 31.7), Offset(73.8, 34.7), Offset(80.7, 41.5), Offset(82.3, 51.5), Offset(79.0, 60.1), Offset(72.1, 67.0), Offset(62.7, 72.4), Offset(52.1, 76.2), Offset(41.2, 78.7)]),
  ]),
  HiraganaChar(kana: 'て', romaji: 'te', bn: 'তে', strokes: [
    _Stroke([Offset(18.8, 24.2), Offset(32.7, 24.4), Offset(46.2, 22.3), Offset(58.0, 20.3), Offset(70.1, 18.2), Offset(80.6, 17.1), Offset(66.5, 20.7), Offset(55.1, 27.1), Offset(46.5, 36.9), Offset(42.0, 48.9), Offset(43.1, 62.6), Offset(50.1, 73.1), Offset(61.1, 79.3), Offset(73.9, 81.3)]),
  ]),
  HiraganaChar(kana: 'と', romaji: 'to', bn: 'তো', strokes: [
    _Stroke([Offset(32.6, 16.9), Offset(34.4, 18.1), Offset(35.9, 20.2), Offset(36.4, 22.2), Offset(36.7, 23.8), Offset(37.1, 26.0), Offset(37.7, 28.8), Offset(38.3, 32.0), Offset(38.9, 35.3), Offset(39.5, 38.6), Offset(40.1, 41.6), Offset(40.6, 44.3), Offset(41.0, 46.3), Offset(41.3, 47.6)]),
    _Stroke([Offset(71.7, 23.4), Offset(67.6, 30.1), Offset(60.9, 34.5), Offset(53.2, 39.6), Offset(44.2, 46.0), Offset(36.6, 52.8), Offset(31.4, 59.5), Offset(29.0, 66.3), Offset(30.0, 73.1), Offset(34.9, 77.7), Offset(43.9, 80.1), Offset(55.5, 80.6), Offset(64.4, 80.4), Offset(73.4, 79.5)]),
  ]),
  HiraganaChar(kana: 'な', romaji: 'na', bn: 'না', strokes: [
    _Stroke([Offset(21.0, 26.6), Offset(23.0, 27.2), Offset(25.7, 27.5), Offset(28.1, 27.4), Offset(30.5, 27.3), Offset(32.9, 27.0), Offset(35.3, 26.6), Offset(37.7, 26.1), Offset(40.1, 25.6), Offset(42.8, 24.9), Offset(45.5, 24.0), Offset(47.9, 23.1), Offset(50.0, 22.2), Offset(51.6, 21.4)]),
    _Stroke([Offset(39.4, 12.8), Offset(39.6, 16.8), Offset(38.7, 20.9), Offset(37.6, 25.0), Offset(36.4, 28.9), Offset(35.0, 32.7), Offset(33.6, 36.4), Offset(32.1, 40.1), Offset(30.5, 43.6), Offset(28.7, 47.1), Offset(26.9, 50.5), Offset(24.9, 54.0), Offset(22.8, 57.4), Offset(20.6, 60.8)]),
    _Stroke([Offset(66.3, 21.3), Offset(68.5, 22.2), Offset(70.6, 23.1), Offset(72.6, 24.0), Offset(74.4, 25.0), Offset(76.0, 26.1), Offset(77.4, 27.2), Offset(78.6, 28.4), Offset(79.5, 29.6), Offset(80.9, 32.3), Offset(81.3, 34.0), Offset(80.3, 34.2), Offset(78.6, 33.7), Offset(76.6, 33.6)]),
    _Stroke([Offset(63.2, 40.9), Offset(61.5, 49.1), Offset(62.3, 57.4), Offset(62.8, 66.0), Offset(60.4, 76.0), Offset(53.2, 81.4), Offset(44.6, 82.2), Offset(38.4, 79.2), Offset(38.3, 72.9), Offset(45.9, 68.9), Offset(53.8, 68.7), Offset(61.9, 70.3), Offset(70.0, 73.6), Offset(77.3, 79.0)]),
  ]),
  HiraganaChar(kana: 'に', romaji: 'ni', bn: 'নি', strokes: [
    _Stroke([Offset(22.5, 20.9), Offset(23.6, 26.1), Offset(22.5, 31.8), Offset(21.2, 37.4), Offset(19.8, 43.1), Offset(18.6, 48.7), Offset(17.5, 54.3), Offset(16.8, 59.8), Offset(16.5, 65.3), Offset(16.8, 70.9), Offset(18.3, 78.5), Offset(20.0, 78.4), Offset(22.1, 73.7), Offset(24.6, 67.2)]),
    _Stroke([Offset(48.8, 28.1), Offset(51.6, 29.3), Offset(55.4, 29.1), Offset(58.9, 28.6), Offset(62.4, 27.9), Offset(65.9, 27.2), Offset(69.5, 26.6), Offset(72.9, 26.3), Offset(77.3, 26.4), Offset(79.1, 27.1), Offset(78.1, 28.2), Offset(75.0, 29.6), Offset(70.8, 31.3), Offset(66.0, 33.0)]),
    _Stroke([Offset(48.2, 62.4), Offset(49.0, 66.0), Offset(50.4, 69.0), Offset(52.2, 71.4), Offset(54.4, 73.3), Offset(57.1, 74.7), Offset(60.0, 75.6), Offset(63.3, 76.1), Offset(66.8, 76.3), Offset(70.5, 76.1), Offset(73.8, 75.8), Offset(76.9, 75.4), Offset(80.1, 74.9), Offset(83.5, 74.2)]),
  ]),
  HiraganaChar(kana: 'ぬ', romaji: 'nu', bn: 'নু', strokes: [
    _Stroke([Offset(23.3, 26.1), Offset(25.7, 29.1), Offset(26.6, 33.2), Offset(27.3, 37.3), Offset(28.0, 41.3), Offset(28.8, 45.3), Offset(29.7, 49.2), Offset(30.7, 53.1), Offset(31.9, 56.9), Offset(33.1, 60.6), Offset(34.6, 64.3), Offset(36.3, 67.8), Offset(38.2, 71.3), Offset(40.5, 74.8)]),
    _Stroke([Offset(52.4, 17.7), Offset(48.7, 37.9), Offset(40.6, 58.9), Offset(28.3, 76.1), Offset(17.5, 64.6), Offset(24.2, 48.3), Offset(42.3, 35.9), Offset(63.4, 32.2), Offset(79.7, 41.9), Offset(82.1, 63.3), Offset(66.0, 79.0), Offset(52.9, 74.0), Offset(67.6, 68.2), Offset(86.5, 79.1)]),
  ]),
  HiraganaChar(kana: 'ね', romaji: 'ne', bn: 'নে', strokes: [
    _Stroke([Offset(30.5, 13.3), Offset(32.3, 17.9), Offset(32.0, 21.9), Offset(31.7, 26.0), Offset(31.4, 30.6), Offset(31.1, 35.5), Offset(30.9, 40.7), Offset(30.6, 46.2), Offset(30.4, 52.0), Offset(30.2, 58.0), Offset(30.0, 64.1), Offset(29.9, 69.9), Offset(29.8, 75.1), Offset(29.7, 80.3)]),
    _Stroke([Offset(15.7, 34.8), Offset(35.1, 30.8), Offset(28.7, 43.8), Offset(17.3, 61.2), Offset(25.7, 56.8), Offset(41.8, 41.6), Offset(57.2, 30.3), Offset(71.5, 26.6), Offset(80.3, 37.5), Offset(80.4, 64.3), Offset(65.0, 76.9), Offset(53.8, 70.8), Offset(68.9, 65.5), Offset(86.4, 75.7)]),
  ]),
  HiraganaChar(kana: 'の', romaji: 'no', bn: 'নো', strokes: [
    _Stroke([Offset(49.4, 26.3), Offset(47.7, 42.6), Offset(41.7, 59.5), Offset(31.5, 74.3), Offset(21.2, 67.2), Offset(16.7, 51.5), Offset(23.8, 37.6), Offset(38.1, 26.6), Offset(56.0, 22.5), Offset(73.6, 28.4), Offset(83.3, 41.6), Offset(83.9, 57.4), Offset(76.0, 71.5), Offset(60.0, 79.7)]),
  ]),
  HiraganaChar(kana: 'は', romaji: 'ha', bn: 'হা', strokes: [
    _Stroke([Offset(22.5, 16.5), Offset(24.1, 22.0), Offset(23.0, 27.7), Offset(21.9, 33.5), Offset(20.9, 39.3), Offset(20.2, 45.2), Offset(19.6, 51.1), Offset(19.3, 57.0), Offset(19.3, 63.0), Offset(19.8, 68.9), Offset(20.9, 76.3), Offset(21.9, 79.3), Offset(23.0, 74.5), Offset(25.5, 67.2)]),
    _Stroke([Offset(45.5, 34.8), Offset(48.1, 36.0), Offset(50.8, 36.5), Offset(53.8, 36.2), Offset(57.0, 35.6), Offset(60.1, 35.1), Offset(63.1, 34.6), Offset(65.9, 34.1), Offset(68.5, 33.5), Offset(71.0, 32.9), Offset(73.3, 32.4), Offset(76.0, 31.7), Offset(79.0, 31.1), Offset(81.3, 31.0)]),
    _Stroke([Offset(64.0, 15.1), Offset(66.7, 22.3), Offset(67.0, 31.0), Offset(67.5, 44.2), Offset(67.9, 57.4), Offset(67.9, 67.4), Offset(62.0, 77.9), Offset(51.4, 81.0), Offset(42.3, 78.6), Offset(40.7, 72.3), Offset(50.0, 69.1), Offset(62.3, 70.6), Offset(71.7, 74.9), Offset(79.3, 80.7)]),
  ]),
  HiraganaChar(kana: 'ひ', romaji: 'hi', bn: 'হি', strokes: [
    _Stroke([Offset(18.3, 23.0), Offset(33.9, 20.6), Offset(33.9, 30.0), Offset(23.3, 49.2), Offset(21.2, 65.0), Offset(26.4, 76.2), Offset(38.2, 81.7), Offset(50.0, 79.8), Offset(60.4, 70.8), Offset(67.7, 54.9), Offset(70.0, 32.3), Offset(71.4, 21.6), Offset(79.1, 40.1), Offset(88.5, 52.4)]),
  ]),
  HiraganaChar(kana: 'ふ', romaji: 'fu', bn: 'ফু', strokes: [
    _Stroke([Offset(39.1, 14.3), Offset(40.6, 15.7), Offset(42.2, 16.8), Offset(43.9, 17.8), Offset(45.6, 18.6), Offset(47.5, 19.2), Offset(49.5, 19.7), Offset(52.2, 20.2), Offset(54.6, 20.9), Offset(55.4, 21.6), Offset(54.9, 22.5), Offset(53.4, 23.4), Offset(51.4, 24.4), Offset(49.1, 25.6)]),
    _Stroke([Offset(40.0, 43.0), Offset(41.7, 45.9), Offset(44.2, 49.0), Offset(47.4, 52.6), Offset(51.2, 56.8), Offset(54.7, 61.3), Offset(56.6, 65.6), Offset(57.0, 69.8), Offset(56.2, 73.7), Offset(54.1, 77.0), Offset(50.9, 79.5), Offset(46.6, 80.8), Offset(41.5, 80.7), Offset(35.6, 78.9)]),
    _Stroke([Offset(15.1, 67.3), Offset(15.6, 69.4), Offset(16.1, 71.4), Offset(16.9, 73.2), Offset(17.9, 74.8), Offset(19.1, 76.2), Offset(20.0, 76.7), Offset(20.3, 76.5), Offset(20.7, 75.8), Offset(21.5, 74.9), Offset(22.8, 73.6), Offset(24.8, 72.0), Offset(27.8, 70.2), Offset(31.9, 68.2)]),
    _Stroke([Offset(73.5, 56.8), Offset(75.6, 58.2), Offset(77.7, 59.7), Offset(79.5, 61.1), Offset(81.2, 62.4), Offset(82.6, 63.6), Offset(83.6, 64.5), Offset(84.9, 66.1), Offset(86.3, 68.5), Offset(86.4, 69.8), Offset(85.4, 70.3), Offset(83.8, 70.5), Offset(81.7, 70.7), Offset(79.7, 71.4)]),
  ]),
  HiraganaChar(kana: 'へ', romaji: 'he', bn: 'হে', strokes: [
    _Stroke([Offset(13.8, 44.7), Offset(20.1, 44.5), Offset(25.2, 39.8), Offset(30.4, 34.8), Offset(36.7, 31.0), Offset(42.4, 33.8), Offset(48.8, 39.1), Offset(55.5, 44.7), Offset(62.1, 50.1), Offset(67.7, 54.7), Offset(71.7, 57.9), Offset(74.8, 60.3), Offset(81.2, 65.8), Offset(85.9, 69.7)]),
  ]),
  HiraganaChar(kana: 'ほ', romaji: 'ho', bn: 'হো', strokes: [
    _Stroke([Offset(22.5, 17.2), Offset(24.1, 22.7), Offset(23.0, 28.5), Offset(21.9, 34.3), Offset(21.0, 40.2), Offset(20.2, 46.2), Offset(19.6, 52.2), Offset(19.3, 58.3), Offset(19.3, 64.3), Offset(19.7, 70.3), Offset(20.8, 77.6), Offset(21.9, 80.9), Offset(22.9, 76.2), Offset(25.5, 68.8)]),
    _Stroke([Offset(48.7, 19.4), Offset(50.7, 20.4), Offset(52.8, 20.8), Offset(55.2, 20.5), Offset(57.7, 20.1), Offset(60.2, 19.7), Offset(62.5, 19.3), Offset(64.7, 18.8), Offset(66.8, 18.4), Offset(68.7, 17.9), Offset(70.5, 17.4), Offset(72.7, 16.9), Offset(75.0, 16.4), Offset(76.8, 16.3)]),
    _Stroke([Offset(49.4, 40.6), Offset(51.7, 41.8), Offset(54.2, 42.2), Offset(57.0, 41.9), Offset(60.0, 41.5), Offset(62.8, 41.0), Offset(65.5, 40.6), Offset(68.0, 40.1), Offset(70.4, 39.6), Offset(72.7, 39.2), Offset(74.8, 38.6), Offset(77.4, 38.0), Offset(80.1, 37.5), Offset(82.2, 37.4)]),
    _Stroke([Offset(66.5, 21.1), Offset(68.1, 28.3), Offset(68.5, 36.8), Offset(69.1, 49.4), Offset(69.7, 61.7), Offset(69.4, 71.3), Offset(62.2, 79.0), Offset(51.4, 80.8), Offset(43.4, 77.7), Offset(44.3, 71.2), Offset(53.7, 68.8), Offset(65.1, 70.6), Offset(74.6, 75.9), Offset(81.8, 81.2)]),
  ]),
  HiraganaChar(kana: 'ま', romaji: 'ma', bn: 'মা', strokes: [
    _Stroke([Offset(27.4, 29.6), Offset(30.6, 30.7), Offset(34.2, 30.7), Offset(37.7, 30.4), Offset(41.4, 30.0), Offset(45.1, 29.5), Offset(48.8, 29.1), Offset(52.5, 28.5), Offset(56.1, 28.0), Offset(59.4, 27.5), Offset(62.6, 26.9), Offset(65.4, 26.4), Offset(69.2, 25.9), Offset(72.3, 25.9)]),
    _Stroke([Offset(31.0, 47.6), Offset(33.9, 48.7), Offset(36.9, 48.9), Offset(40.1, 48.4), Offset(43.3, 47.9), Offset(46.4, 47.4), Offset(49.4, 46.8), Offset(52.4, 46.3), Offset(55.4, 45.7), Offset(58.4, 45.0), Offset(61.4, 44.4), Offset(64.7, 43.6), Offset(68.1, 43.0), Offset(70.7, 42.8)]),
    _Stroke([Offset(51.2, 12.8), Offset(52.9, 21.0), Offset(53.0, 31.1), Offset(53.1, 45.9), Offset(53.2, 60.6), Offset(53.1, 71.6), Offset(45.9, 82.4), Offset(34.1, 84.6), Offset(26.1, 80.1), Offset(28.8, 73.2), Offset(39.8, 70.7), Offset(53.5, 72.5), Offset(65.4, 77.7), Offset(74.7, 83.7)]),
  ]),
  HiraganaChar(kana: 'み', romaji: 'mi', bn: 'মি', strokes: [
    _Stroke([Offset(29.8, 23.9), Offset(42.9, 23.4), Offset(51.1, 27.1), Offset(47.1, 37.6), Offset(40.9, 52.8), Offset(29.3, 72.6), Offset(19.0, 78.3), Offset(13.5, 73.6), Offset(17.4, 63.0), Offset(30.5, 58.7), Offset(45.3, 59.4), Offset(59.7, 62.4), Offset(72.1, 66.5), Offset(84.3, 72.2)]),
    _Stroke([Offset(72.8, 50.2), Offset(73.2, 53.7), Offset(72.7, 56.5), Offset(72.0, 58.8), Offset(71.2, 61.3), Offset(70.2, 64.1), Offset(69.0, 67.1), Offset(67.6, 70.1), Offset(65.9, 73.2), Offset(63.9, 76.3), Offset(61.5, 79.2), Offset(58.9, 82.0), Offset(55.9, 84.6), Offset(52.5, 86.9)]),
  ]),
  HiraganaChar(kana: 'む', romaji: 'mu', bn: 'মু', strokes: [
    _Stroke([Offset(18.0, 29.0), Offset(20.4, 30.2), Offset(23.0, 30.3), Offset(25.8, 29.9), Offset(28.5, 29.4), Offset(31.1, 28.9), Offset(33.7, 28.3), Offset(36.3, 27.8), Offset(38.8, 27.2), Offset(41.4, 26.6), Offset(44.0, 26.0), Offset(46.9, 25.3), Offset(49.7, 24.7), Offset(52.0, 24.4)]),
    _Stroke([Offset(34.0, 14.2), Offset(35.3, 27.1), Offset(33.9, 40.5), Offset(30.0, 58.3), Offset(19.2, 64.4), Offset(15.8, 54.2), Offset(25.7, 45.6), Offset(35.1, 49.6), Offset(26.8, 68.2), Offset(25.3, 79.2), Offset(37.4, 82.6), Offset(51.9, 82.9), Offset(67.5, 80.9), Offset(69.7, 71.6)]),
    _Stroke([Offset(72.0, 33.3), Offset(74.4, 34.4), Offset(76.6, 35.4), Offset(78.5, 36.5), Offset(80.4, 37.7), Offset(82.0, 38.9), Offset(83.5, 40.1), Offset(84.8, 41.5), Offset(86.4, 43.5), Offset(87.8, 46.2), Offset(87.4, 47.1), Offset(85.7, 47.0), Offset(83.5, 46.6), Offset(81.6, 46.7)]),
  ]),
  HiraganaChar(kana: 'め', romaji: 'me', bn: 'মে', strokes: [
    _Stroke([Offset(25.2, 29.1), Offset(27.2, 31.9), Offset(27.6, 35.7), Offset(27.9, 39.6), Offset(28.4, 43.4), Offset(29.0, 47.2), Offset(29.7, 50.8), Offset(30.7, 54.3), Offset(31.8, 57.6), Offset(33.0, 60.6), Offset(34.4, 63.2), Offset(36.4, 66.3), Offset(38.8, 69.8), Offset(40.8, 72.3)]),
    _Stroke([Offset(54.7, 17.8), Offset(52.8, 33.8), Offset(45.8, 51.0), Offset(38.3, 65.3), Offset(25.3, 77.7), Offset(16.5, 67.5), Offset(18.9, 55.5), Offset(30.5, 43.5), Offset(47.6, 35.6), Offset(66.6, 35.7), Offset(80.2, 45.8), Offset(82.9, 60.2), Offset(75.4, 73.9), Offset(58.3, 81.4)]),
  ]),
  HiraganaChar(kana: 'も', romaji: 'mo', bn: 'মো', strokes: [
    _Stroke([Offset(45.1, 13.5), Offset(45.6, 23.3), Offset(43.7, 33.1), Offset(42.1, 42.7), Offset(40.6, 52.8), Offset(39.1, 64.7), Offset(39.3, 75.9), Offset(42.8, 83.2), Offset(50.9, 86.6), Offset(62.2, 86.3), Offset(70.7, 82.6), Offset(75.6, 75.9), Offset(76.7, 66.3), Offset(73.7, 54.1)]),
    _Stroke([Offset(24.3, 31.8), Offset(26.5, 33.1), Offset(30.1, 33.6), Offset(33.6, 33.3), Offset(37.0, 33.0), Offset(40.2, 32.6), Offset(43.3, 32.3), Offset(46.3, 31.9), Offset(49.1, 31.4), Offset(51.9, 31.0), Offset(54.5, 30.6), Offset(57.7, 30.0), Offset(60.6, 29.6), Offset(63.4, 29.5)]),
    _Stroke([Offset(24.2, 49.0), Offset(23.9, 51.6), Offset(25.2, 53.6), Offset(28.0, 54.8), Offset(32.1, 55.2), Offset(35.6, 55.1), Offset(39.0, 54.9), Offset(42.3, 54.7), Offset(45.4, 54.4), Offset(48.3, 54.0), Offset(50.8, 53.7), Offset(53.2, 53.3), Offset(56.2, 52.7), Offset(59.2, 51.8)]),
  ]),
  HiraganaChar(kana: 'や', romaji: 'ya', bn: 'ইয়া', strokes: [
    _Stroke([Offset(16.5, 45.3), Offset(24.4, 46.1), Offset(32.9, 41.9), Offset(41.1, 37.8), Offset(49.1, 34.1), Offset(56.8, 31.1), Offset(64.2, 29.1), Offset(71.4, 28.4), Offset(80.1, 30.5), Offset(85.1, 36.1), Offset(84.9, 43.3), Offset(80.5, 49.2), Offset(72.9, 53.7), Offset(63.2, 56.1)]),
    _Stroke([Offset(43.2, 14.6), Offset(44.8, 14.9), Offset(46.4, 15.4), Offset(48.0, 16.0), Offset(49.4, 16.7), Offset(50.7, 17.5), Offset(51.8, 18.3), Offset(52.8, 19.2), Offset(53.4, 20.0), Offset(54.1, 21.4), Offset(54.4, 23.1), Offset(53.7, 23.5), Offset(52.5, 23.2), Offset(51.1, 23.0)]),
    _Stroke([Offset(27.5, 22.4), Offset(30.7, 26.1), Offset(31.7, 29.7), Offset(32.8, 33.9), Offset(34.1, 38.7), Offset(35.6, 44.1), Offset(37.2, 49.7), Offset(38.8, 55.5), Offset(40.4, 61.0), Offset(41.9, 66.2), Offset(43.2, 70.9), Offset(44.4, 74.7), Offset(45.7, 78.7), Offset(47.3, 84.0)]),
  ]),
  HiraganaChar(kana: 'ゆ', romaji: 'yu', bn: 'ইউ', strokes: [
    _Stroke([Offset(19.3, 23.3), Offset(18.9, 37.9), Offset(17.9, 52.7), Offset(20.3, 69.6), Offset(23.5, 55.8), Offset(32.8, 41.9), Offset(44.6, 32.7), Offset(57.6, 28.4), Offset(73.9, 30.7), Offset(81.9, 41.7), Offset(80.4, 57.3), Offset(69.7, 67.3), Offset(55.4, 68.5), Offset(43.1, 62.0)]),
    _Stroke([Offset(53.6, 15.4), Offset(56.5, 19.5), Offset(57.1, 25.7), Offset(57.5, 31.3), Offset(57.9, 36.7), Offset(58.1, 42.2), Offset(58.3, 48.1), Offset(58.2, 56.6), Offset(57.3, 63.9), Offset(55.9, 69.8), Offset(54.0, 74.6), Offset(51.8, 78.5), Offset(49.4, 81.9), Offset(46.9, 84.9)]),
  ]),
  HiraganaChar(kana: 'よ', romaji: 'yo', bn: 'ইও', strokes: [
    _Stroke([Offset(53.4, 32.5), Offset(55.5, 32.1), Offset(57.5, 31.7), Offset(59.5, 31.4), Offset(61.3, 31.0), Offset(63.1, 30.6), Offset(64.8, 30.2), Offset(66.4, 29.8), Offset(67.9, 29.4), Offset(69.4, 29.0), Offset(71.0, 28.5), Offset(73.0, 28.0), Offset(74.7, 27.7), Offset(76.1, 27.6)]),
    _Stroke([Offset(50.1, 12.7), Offset(52.6, 23.8), Offset(52.5, 35.6), Offset(52.8, 47.6), Offset(53.4, 59.9), Offset(53.5, 73.5), Offset(44.7, 82.7), Offset(31.7, 84.3), Offset(22.7, 80.3), Offset(25.2, 73.0), Offset(37.4, 71.0), Offset(51.1, 73.3), Offset(62.1, 77.6), Offset(72.0, 84.1)]),
  ]),
  HiraganaChar(kana: 'ら', romaji: 'ra', bn: 'রা', strokes: [
    _Stroke([Offset(32.4, 13.8), Offset(33.8, 14.8), Offset(35.4, 15.6), Offset(37.1, 16.3), Offset(39.0, 16.9), Offset(41.1, 17.3), Offset(43.3, 17.5), Offset(45.7, 17.7), Offset(49.0, 17.6), Offset(51.8, 17.9), Offset(51.7, 18.5), Offset(49.9, 19.3), Offset(47.7, 20.2), Offset(46.4, 20.9)]),
    _Stroke([Offset(32.9, 32.8), Offset(30.2, 42.9), Offset(29.6, 52.9), Offset(27.3, 65.7), Offset(31.3, 65.3), Offset(41.3, 58.6), Offset(50.6, 55.2), Offset(60.0, 54.2), Offset(70.5, 56.9), Offset(75.9, 64.9), Offset(74.4, 74.2), Offset(68.2, 81.1), Offset(58.5, 85.6), Offset(46.3, 87.6)]),
  ]),
  HiraganaChar(kana: 'り', romaji: 'ri', bn: 'রি', strokes: [
    _Stroke([Offset(35.6, 23.2), Offset(37.2, 27.4), Offset(36.4, 31.9), Offset(35.4, 36.4), Offset(34.5, 41.2), Offset(33.7, 46.1), Offset(33.1, 51.1), Offset(32.7, 56.1), Offset(32.6, 61.0), Offset(32.8, 65.6), Offset(33.7, 71.3), Offset(34.8, 72.4), Offset(36.0, 67.9), Offset(38.3, 62.4)]),
    _Stroke([Offset(63.6, 17.2), Offset(66.2, 22.1), Offset(66.3, 25.1), Offset(66.3, 29.9), Offset(66.3, 36.3), Offset(66.3, 43.5), Offset(66.3, 50.3), Offset(66.3, 55.8), Offset(65.9, 62.8), Offset(64.9, 68.9), Offset(63.2, 74.2), Offset(60.8, 78.8), Offset(58.0, 82.8), Offset(54.7, 86.3)]),
  ]),
  HiraganaChar(kana: 'る', romaji: 'ru', bn: 'রু', strokes: [
    _Stroke([Offset(31.5, 18.7), Offset(47.2, 17.9), Offset(57.3, 20.1), Offset(48.2, 32.0), Offset(35.3, 47.5), Offset(25.0, 58.6), Offset(41.6, 49.9), Offset(58.8, 48.5), Offset(70.7, 57.7), Offset(68.7, 76.0), Offset(51.6, 84.1), Offset(36.3, 81.1), Offset(40.8, 71.0), Offset(57.2, 77.4)]),
  ]),
  HiraganaChar(kana: 'れ', romaji: 're', bn: 'রে', strokes: [
    _Stroke([Offset(31.6, 11.9), Offset(34.0, 16.8), Offset(33.8, 19.7), Offset(33.5, 24.0), Offset(33.1, 30.0), Offset(32.7, 36.9), Offset(32.3, 44.3), Offset(31.9, 51.6), Offset(31.6, 58.2), Offset(31.5, 63.4), Offset(31.4, 67.6), Offset(31.4, 74.6), Offset(31.5, 80.4), Offset(31.5, 84.2)]),
    _Stroke([Offset(15.6, 37.4), Offset(29.4, 34.5), Offset(34.8, 38.8), Offset(26.6, 51.1), Offset(15.6, 66.4), Offset(23.5, 62.6), Offset(35.1, 51.4), Offset(45.5, 41.5), Offset(58.2, 30.4), Offset(70.0, 31.5), Offset(68.9, 48.5), Offset(67.9, 64.0), Offset(74.1, 77.6), Offset(86.4, 70.9)]),
  ]),
  HiraganaChar(kana: 'ろ', romaji: 'ro', bn: 'রো', strokes: [
    _Stroke([Offset(33.9, 20.1), Offset(46.5, 21.0), Offset(59.4, 19.1), Offset(51.4, 30.7), Offset(42.4, 42.0), Offset(33.1, 53.8), Offset(27.5, 61.8), Offset(42.9, 52.5), Offset(58.2, 48.7), Offset(71.3, 51.3), Offset(77.8, 61.7), Offset(74.4, 74.9), Offset(63.4, 83.0), Offset(48.5, 87.1)]),
  ]),
  HiraganaChar(kana: 'わ', romaji: 'wa', bn: 'ওয়া', strokes: [
    _Stroke([Offset(35.3, 13.5), Offset(37.2, 18.5), Offset(36.9, 23.2), Offset(36.5, 28.7), Offset(36.1, 34.9), Offset(35.7, 41.7), Offset(35.4, 48.4), Offset(35.1, 54.8), Offset(34.8, 60.6), Offset(34.7, 65.2), Offset(34.7, 69.3), Offset(34.5, 76.2), Offset(34.2, 82.0), Offset(34.1, 85.8)]),
    _Stroke([Offset(16.1, 37.4), Offset(30.7, 34.7), Offset(40.5, 35.4), Offset(31.5, 46.7), Offset(21.1, 59.9), Offset(17.6, 68.0), Offset(33.5, 55.1), Offset(48.8, 45.3), Offset(63.4, 39.8), Offset(75.9, 40.8), Offset(85.2, 50.6), Offset(85.5, 63.9), Offset(76.3, 75.8), Offset(59.7, 83.6)]),
  ]),
  HiraganaChar(kana: 'を', romaji: 'wo', bn: 'ও', strokes: [
    _Stroke([Offset(26.2, 25.6), Offset(28.5, 26.6), Offset(31.5, 26.6), Offset(35.0, 26.0), Offset(38.1, 25.4), Offset(41.0, 24.8), Offset(43.7, 24.3), Offset(46.2, 23.8), Offset(48.7, 23.3), Offset(51.2, 22.8), Offset(53.7, 22.4), Offset(56.8, 21.9), Offset(59.5, 21.6), Offset(62.1, 21.6)]),
    _Stroke([Offset(45.8, 13.2), Offset(45.3, 20.2), Offset(42.1, 26.9), Offset(38.6, 33.5), Offset(34.7, 40.0), Offset(30.1, 46.6), Offset(24.6, 54.0), Offset(26.5, 53.0), Offset(33.9, 47.3), Offset(39.2, 44.5), Offset(44.6, 43.7), Offset(49.2, 46.3), Offset(52.4, 53.5), Offset(53.4, 66.6)]),
    _Stroke([Offset(76.2, 36.6), Offset(73.1, 42.0), Offset(69.0, 44.2), Offset(61.7, 48.2), Offset(52.9, 53.4), Offset(44.1, 59.5), Offset(36.8, 65.9), Offset(32.6, 72.3), Offset(33.0, 78.3), Offset(38.0, 82.8), Offset(45.7, 84.6), Offset(54.7, 84.5), Offset(63.6, 83.6), Offset(71.3, 82.5)]),
  ]),
  HiraganaChar(kana: 'ん', romaji: 'n', bn: 'ন', strokes: [
    _Stroke([Offset(51.7, 15.1), Offset(48.6, 27.1), Offset(40.6, 40.0), Offset(31.4, 54.7), Offset(23.3, 67.7), Offset(15.5, 81.2), Offset(19.2, 77.6), Offset(33.6, 58.8), Offset(44.8, 55.0), Offset(50.6, 63.0), Offset(52.6, 77.8), Offset(59.8, 84.6), Offset(70.6, 80.0), Offset(82.4, 63.0)]),
  ]),
];


// ── Drawing game screen ─────────────────────────────────────────────────────

class HiraganaDrawGameScreen extends StatefulWidget {
  const HiraganaDrawGameScreen({
    super.key,
    this.initialIndex = 0,
    this.embedded = false,
    this.autoAdvance = false,
  });
  final int initialIndex;

  /// When true, omit the surrounding Scaffold/SafeArea and the back button so
  /// the widget can be dropped inside another screen (e.g. as a tab body).
  final bool embedded;

  /// When true, completion automatically advances to the next character
  /// after a short pause — skips the freehand-from-memory phase.
  final bool autoAdvance;

  @override
  State<HiraganaDrawGameScreen> createState() => _HiraganaDrawGameScreenState();
}

enum _GameMode { tracing, freehand, completed }

class _HiraganaDrawGameScreenState extends State<HiraganaDrawGameScreen>
    with TickerProviderStateMixin {
  late int _charIdx;
  _GameMode _mode = _GameMode.tracing;
  bool _showShadow = true;

  int _strokeIdx = 0;
  List<Offset> _currentPath = [];
  final List<List<Offset>> _completedStrokes = [];
  bool _showError = false;
  Timer? _errorTimer;

  late AnimationController _tracerCtrl;
  late AnimationController _completeCtrl;

  final FlutterTts _tts = FlutterTts();

  HiraganaChar get _char => kHiraganaSet[_charIdx];

  @override
  void initState() {
    super.initState();
    _charIdx = widget.initialIndex.clamp(0, kHiraganaSet.length - 1);
    _tracerCtrl = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
    _completeCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tracerCtrl.dispose();
    _completeCtrl.dispose();
    _errorTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  void _resetForChar() {
    setState(() {
      _strokeIdx = 0;
      _currentPath = [];
      _completedStrokes.clear();
      _showError = false;
      _mode = _GameMode.tracing;
      _showShadow = true;
    });
    _completeCtrl.reset();
  }

  void _clear() {
    HapticFeedback.selectionClick();
    setState(() {
      _strokeIdx = 0;
      _currentPath = [];
      _completedStrokes.clear();
      _showError = false;
      if (_mode == _GameMode.completed) _mode = _GameMode.tracing;
    });
    _completeCtrl.reset();
  }

  Future<void> _speak() async {
    HapticFeedback.selectionClick();
    try {
      await _tts.stop();
      await _tts.speak(_char.kana);
    } catch (_) {}
  }

  void _toggleShadow() {
    HapticFeedback.selectionClick();
    setState(() => _showShadow = !_showShadow);
  }

  void _advance() {
    if (_mode == _GameMode.tracing) {
      _resetForChar();
      setState(() {
        _mode = _GameMode.freehand;
        _showShadow = false;
      });
    } else if (_mode == _GameMode.freehand) {
      if (_charIdx < kHiraganaSet.length - 1) {
        setState(() => _charIdx++);
        _resetForChar();
      } else {
        Get.back();
      }
    }
  }

  void _prevChar() {
    if (_charIdx > 0) {
      setState(() => _charIdx--);
      _resetForChar();
    }
  }

  void _nextChar() {
    if (_charIdx < kHiraganaSet.length - 1) {
      setState(() => _charIdx++);
      _resetForChar();
    }
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validate(List<Offset> userPath, _Stroke target, double canvasSize) {
    if (userPath.length < 4) return false;

    final tolStart = canvasSize * 0.18;
    final tolEnd = canvasSize * 0.22;
    final tolMid = canvasSize * 0.28;

    final tgtCanvas = target.points
        .map((p) => Offset(p.dx * canvasSize / 100, p.dy * canvasSize / 100))
        .toList();

    // Start point near target start
    if ((userPath.first - tgtCanvas.first).distance > tolStart) return false;
    // End point near target end
    if ((userPath.last - tgtCanvas.last).distance > tolEnd) return false;

    // Sample 4 midpoints along user path and ensure each is within tolerance
    // of *any* point on the target polyline (forgiving but checks shape).
    final samples = [0.25, 0.5, 0.75];
    for (final t in samples) {
      final idx = (userPath.length * t).floor();
      final sample = userPath[idx];
      final dist = _minDistToPolyline(sample, tgtCanvas);
      if (dist > tolMid) return false;
    }

    // Direction check: ensure user moved generally from start->end in the
    // same direction as the target by comparing displacement vectors.
    final userVec = userPath.last - userPath.first;
    final tgtVec = tgtCanvas.last - tgtCanvas.first;
    if (userVec.distance < canvasSize * 0.08) return false;
    final dot = (userVec.dx * tgtVec.dx + userVec.dy * tgtVec.dy) /
        (userVec.distance * tgtVec.distance);
    if (dot < 0.3) return false;

    return true;
  }

  double _minDistToPolyline(Offset p, List<Offset> poly) {
    double best = double.infinity;
    for (int i = 0; i < poly.length - 1; i++) {
      final d = _distToSegment(p, poly[i], poly[i + 1]);
      if (d < best) best = d;
    }
    return best;
  }

  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final abLen2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (abLen2 == 0) return (p - a).distance;
    double t = (ap.dx * ab.dx + ap.dy * ab.dy) / abLen2;
    t = t.clamp(0.0, 1.0);
    final proj = a + Offset(ab.dx * t, ab.dy * t);
    return (p - proj).distance;
  }

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails d, double size) {
    if (_mode == _GameMode.completed) return;
    if (_strokeIdx >= _char.strokes.length) return;
    setState(() {
      _currentPath = [d.localPosition];
      _showError = false;
      _errorTimer?.cancel();
    });
  }

  void _onPanUpdate(DragUpdateDetails d, double size) {
    if (_mode == _GameMode.completed) return;
    if (_strokeIdx >= _char.strokes.length) return;
    setState(() => _currentPath = [..._currentPath, d.localPosition]);
  }

  void _onPanEnd(DragEndDetails d, double size) {
    if (_mode == _GameMode.completed) return;
    if (_strokeIdx >= _char.strokes.length) return;
    final target = _char.strokes[_strokeIdx];
    if (_validate(_currentPath, target, size)) {
      HapticFeedback.lightImpact();
      setState(() {
        _completedStrokes.add(List.of(_currentPath));
        _currentPath = [];
        _strokeIdx++;
        if (_strokeIdx >= _char.strokes.length) {
          _mode = _GameMode.completed;
          _completeCtrl.forward();
        }
      });
      if (_mode == _GameMode.completed) {
        Future.delayed(const Duration(milliseconds: 200), _speak);
        if (widget.autoAdvance &&
            _charIdx < kHiraganaSet.length - 1) {
          Future.delayed(const Duration(milliseconds: 1400), () {
            if (!mounted) return;
            if (_mode != _GameMode.completed) return;
            setState(() => _charIdx++);
            _resetForChar();
          });
        }
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _showError = true;
        _currentPath = [];
      });
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLast = _charIdx >= kHiraganaSet.length - 1;
    final content = Column(
      children: [
        _Header(
          charIdx: _charIdx,
          total: kHiraganaSet.length,
          showBack: !widget.embedded,
          onBack: Get.back,
          onPrev: _charIdx > 0 ? _prevChar : null,
          onNext: _charIdx < kHiraganaSet.length - 1 ? _nextChar : null,
        ),
        const SizedBox(height: 4),
        _CharacterLabel(char: _char),
        const SizedBox(height: 14),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, c) {
                  final size =
                      math.min(c.maxWidth, c.maxHeight).clamp(220.0, 380.0);
                  return SizedBox(
                    width: size,
                    height: size,
                    child: GestureDetector(
                      onPanStart: (d) => _onPanStart(d, size),
                      onPanUpdate: (d) => _onPanUpdate(d, size),
                      onPanEnd: (d) => _onPanEnd(d, size),
                      child: AnimatedBuilder(
                        animation:
                            Listenable.merge([_tracerCtrl, _completeCtrl]),
                        builder: (ctx, _) {
                          return CustomPaint(
                            size: Size(size, size),
                            painter: _CharPainter(
                              character: _char,
                              strokeIdx: _strokeIdx,
                              currentPath: _currentPath,
                              completedStrokes: _completedStrokes,
                              showShadow: _showShadow &&
                                  _mode != _GameMode.freehand,
                              showStrokeHints:
                                  _mode == _GameMode.tracing,
                              completed: _mode == _GameMode.completed,
                              tracerProgress: _tracerCtrl.value,
                              completeProgress: _completeCtrl.value,
                              showError: _showError,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ButtonsRow(
          onClear: _clear,
          onAudio: _speak,
          onToggle: _toggleShadow,
          shadowOn: _showShadow,
        ),
        const SizedBox(height: 12),
        _Footer(
          mode: _mode,
          strokeIdx: _strokeIdx,
          totalStrokes: _char.strokes.length,
          autoAdvance: widget.autoAdvance,
          isLast: isLast,
          onAdvance: (widget.autoAdvance || _mode != _GameMode.completed)
              ? null
              : _advance,
        ),
        const SizedBox(height: 14),
      ],
    );

    if (widget.embedded) {
      return Container(
        color: const Color(0xFF0B1220),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(child: content),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.charIdx,
    required this.total,
    required this.showBack,
    required this.onBack,
    required this.onPrev,
    required this.onNext,
  });
  final int charIdx;
  final int total;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          const Spacer(),
          _IconBtn(
            icon: Icons.chevron_left_rounded,
            onTap: onPrev,
            enabled: onPrev != null,
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              '${charIdx + 1} / $total',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _IconBtn(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
            enabled: onNext != null,
          ),
          const Spacer(),
          if (showBack) const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon, required this.onTap, required this.enabled});
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white
              .withValues(alpha: enabled ? 0.12 : 0.04),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.3),
            size: 22),
      ),
    );
  }
}

// ── Character label ──────────────────────────────────────────────────────────

class _CharacterLabel extends StatelessWidget {
  const _CharacterLabel({required this.char});
  final HiraganaChar char;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          char.romaji,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 32,
            letterSpacing: 1.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'হিরাগানা · ${char.bn}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Buttons row ──────────────────────────────────────────────────────────────

class _ButtonsRow extends StatelessWidget {
  const _ButtonsRow({
    required this.onClear,
    required this.onAudio,
    required this.onToggle,
    required this.shadowOn,
  });
  final VoidCallback onClear;
  final VoidCallback onAudio;
  final VoidCallback onToggle;
  final bool shadowOn;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleBtn(icon: Icons.delete_outline_rounded, onTap: onClear),
        const SizedBox(width: 18),
        _CircleBtn(icon: Icons.volume_up_rounded, onTap: onAudio, primary: true),
        const SizedBox(width: 18),
        _CircleBtn(
          icon: shadowOn
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
          onTap: onToggle,
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.primary = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: primary ? 60 : 52,
        height: primary ? 60 : 52,
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: primary ? null : Colors.white.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: primary ? 0.0 : 0.15),
            width: 1.2,
          ),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: Colors.white, size: primary ? 26 : 22),
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({
    required this.mode,
    required this.strokeIdx,
    required this.totalStrokes,
    required this.onAdvance,
    this.autoAdvance = false,
    this.isLast = false,
  });
  final _GameMode mode;
  final int strokeIdx;
  final int totalStrokes;
  final VoidCallback? onAdvance;
  final bool autoAdvance;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    switch (mode) {
      case _GameMode.tracing:
        text = 'স্ট্রোক ${strokeIdx + 1} / $totalStrokes — ছায়া অনুসরণ করে আঁকো';
        color = Colors.white.withValues(alpha: 0.75);
        break;
      case _GameMode.freehand:
        text = 'স্মৃতি থেকে আঁকো — স্ট্রোক ${strokeIdx + 1} / $totalStrokes';
        color = const Color(0xFFFFE000);
        break;
      case _GameMode.completed:
        if (autoAdvance) {
          text = isLast
              ? 'দারুণ! তুমি সব ৪৬টি হিরাগানা শেষ করেছ!'
              : 'দারুণ! পরের অক্ষর আসছে...';
        } else {
          text = 'দারুণ! পরের ধাপে যেতে এখানে ট্যাপ করো';
        }
        color = const Color(0xFF3B82F6);
        break;
    }

    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                height: 1.3,
              ),
            ),
          ),
          if (mode == _GameMode.completed) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded,
                color: Color(0xFF3B82F6), size: 18),
          ],
        ],
      ),
    );

    if (onAdvance != null) {
      return GestureDetector(onTap: onAdvance, child: body);
    }
    return body;
  }
}

// ── Painter ──────────────────────────────────────────────────────────────────

class _CharPainter extends CustomPainter {
  _CharPainter({
    required this.character,
    required this.strokeIdx,
    required this.currentPath,
    required this.completedStrokes,
    required this.showShadow,
    required this.showStrokeHints,
    required this.completed,
    required this.tracerProgress,
    required this.completeProgress,
    required this.showError,
  });

  final HiraganaChar character;
  final int strokeIdx;
  final List<Offset> currentPath;
  final List<List<Offset>> completedStrokes;
  final bool showShadow;
  final bool showStrokeHints;
  final bool completed;
  final double tracerProgress;
  final double completeProgress;
  final bool showError;

  static const _strokeWidth = 15.0;
  static const _strokeCorrectColor = Color(0xFF3B82F6);
  static const _strokeErrorColor = Color(0xFFFFE000);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    _drawBackground(canvas, size);
    _drawGrid(canvas, size);

    // Shadow template (faded full character) — only on tracing mode.
    if (showShadow) {
      for (int i = strokeIdx; i < character.strokes.length; i++) {
        _drawCalligraphicStroke(canvas, character.strokes[i], s,
            color: Colors.white.withValues(alpha: 0.16),
            baseWidth: _strokeWidth);
      }
    }

    // Completed strokes — rendered with a brush-like variable width.
    for (int i = 0; i < strokeIdx; i++) {
      final color = completed
          ? Color.lerp(Colors.white, _strokeCorrectColor,
              completeProgress.clamp(0.0, 1.0))!
          : Colors.white;
      _drawCalligraphicStroke(canvas, character.strokes[i], s,
          color: color, baseWidth: _strokeWidth);
    }

    // User's in-progress path.
    if (currentPath.isNotEmpty) {
      final paint = Paint()
        ..color = showError ? _strokeErrorColor : const Color(0xFFFFE000)
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(currentPath.first.dx, currentPath.first.dy);
      for (int i = 1; i < currentPath.length; i++) {
        path.lineTo(currentPath[i].dx, currentPath[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Error overlay.
    if (showError) {
      final paint = Paint()
        ..color = _strokeErrorColor.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, s, s), const Radius.circular(18)),
        paint,
      );
    }

    // Tracer dot — guides user along the active stroke.
    if (!completed &&
        currentPath.isEmpty &&
        strokeIdx < character.strokes.length &&
        showStrokeHints) {
      _drawTracerDot(canvas, character.strokes[strokeIdx], s, tracerProgress);
      _drawStartHint(canvas, character.strokes[strokeIdx], s);
    }

    // Completion glow.
    if (completed && completeProgress > 0) {
      final glow = Paint()
        ..color = _strokeCorrectColor
            .withValues(alpha: 0.25 * completeProgress)
        ..maskFilter =
            const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(-10, -10, s + 20, s + 20),
            const Radius.circular(24)),
        glow,
      );
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF111827), Color(0xFF1E293B)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(18)),
      paint,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0.6, 0.6, size.width - 1.2, size.height - 1.2),
          const Radius.circular(18)),
      border,
    );

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    _dashedLine(canvas, Offset(0, cy), Offset(size.width, cy), dashPaint);
    _dashedLine(canvas, Offset(cx, 0), Offset(cx, size.height), dashPaint);
    _dashedLine(canvas, const Offset(0, 0),
        Offset(size.width, size.height), dashPaint);
    _dashedLine(canvas, Offset(0, size.height),
        Offset(size.width, 0), dashPaint);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 5.0;
    const gap = 5.0;
    final delta = b - a;
    final length = delta.distance;
    if (length == 0) return;
    final dir = Offset(delta.dx / length, delta.dy / length);
    double t = 0;
    while (t < length) {
      final end = math.min(t + dash, length);
      canvas.drawLine(
        a + Offset(dir.dx * t, dir.dy * t),
        a + Offset(dir.dx * end, dir.dy * end),
        paint,
      );
      t += dash + gap;
    }
  }

  // Variable-width "brush" stroke: stamps filled circles along the path with
  // radius driven by [_calligraphicWidthProfile] to mimic the natural
  // pen-down → body → harai (taper) rhythm of real hiragana strokes.
  void _drawCalligraphicStroke(
    Canvas canvas,
    _Stroke stroke,
    double s, {
    required Color color,
    required double baseWidth,
  }) {
    final path = _buildPath(stroke, s);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final m = metrics.first;
    final length = m.length;
    if (length < 1) return;

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    // ~1 stamp per ~1.5 px of path length; bounded for perf.
    final samples =
        math.min(140, math.max(40, (length / 1.5).round()));

    for (int i = 0; i <= samples; i++) {
      final t = i / samples;
      final tan = m.getTangentForOffset(length * t);
      if (tan == null) continue;
      final widthMul = _calligraphicWidthProfile(t);
      final radius = (baseWidth * widthMul) / 2;
      if (radius < 0.4) continue;
      canvas.drawCircle(tan.position, radius, paint);
    }
  }

  // Width multiplier along the stroke (t in 0..1).
  //   pen-down ramp → full body → gradual taper → sweep-off.
  double _calligraphicWidthProfile(double t) {
    if (t < 0.10) {
      return 0.65 + 0.35 * (t / 0.10);
    } else if (t < 0.55) {
      return 1.0;
    } else if (t < 0.90) {
      return 1.0 - 0.55 * ((t - 0.55) / 0.35);
    } else {
      return 0.45 - 0.35 * ((t - 0.90) / 0.10);
    }
  }

  Path _buildPath(_Stroke stroke, double s) {
    final path = Path();
    final pts = stroke.points;
    if (pts.isEmpty) return path;
    Offset toCanvas(Offset p) => Offset(p.dx * s / 100, p.dy * s / 100);
    path.moveTo(toCanvas(pts.first).dx, toCanvas(pts.first).dy);
    if (pts.length == 2) {
      path.lineTo(toCanvas(pts[1]).dx, toCanvas(pts[1]).dy);
    } else {
      for (int i = 1; i < pts.length - 1; i++) {
        final c = toCanvas(pts[i]);
        final n = toCanvas(pts[i + 1]);
        final mid = Offset((c.dx + n.dx) / 2, (c.dy + n.dy) / 2);
        path.quadraticBezierTo(c.dx, c.dy, mid.dx, mid.dy);
      }
      final last = toCanvas(pts.last);
      path.lineTo(last.dx, last.dy);
    }
    return path;
  }

  void _drawTracerDot(Canvas canvas, _Stroke stroke, double s, double t) {
    final path = _buildPath(stroke, s);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final m = metrics.first;
    final pos = m.getTangentForOffset(m.length * t)?.position;
    if (pos == null) return;

    final outer = Paint()
      ..color = const Color(0xFFFFE000).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(pos, 14, outer);

    final core = Paint()..color = const Color(0xFFFFE000);
    canvas.drawCircle(pos, 6, core);

    final inner = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 2.5, inner);
  }

  void _drawStartHint(Canvas canvas, _Stroke stroke, double s) {
    final start = Offset(stroke.points.first.dx * s / 100,
        stroke.points.first.dy * s / 100);
    final ringPaint = Paint()
      ..color = const Color(0xFFFFE000).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(start, 14, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _CharPainter old) {
    return old.strokeIdx != strokeIdx ||
        old.currentPath != currentPath ||
        old.completedStrokes.length != completedStrokes.length ||
        old.showShadow != showShadow ||
        old.completed != completed ||
        old.tracerProgress != tracerProgress ||
        old.completeProgress != completeProgress ||
        old.showError != showError ||
        old.character.kana != character.kana;
  }
}
