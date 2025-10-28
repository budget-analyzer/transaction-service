package com.bleurubin.budgetanalyzer.domain;

import java.util.Map;

public record CsvRow(int lineNumber, Map<String, String> values) {}
