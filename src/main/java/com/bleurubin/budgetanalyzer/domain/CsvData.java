package com.bleurubin.budgetanalyzer.domain;

import java.util.List;
import java.util.Map;

public record CsvData(String fileName, List<Map<String, String>> rows) {
  public CsvData {
    if (rows == null) {
      rows = List.of();
    }
  }
}
