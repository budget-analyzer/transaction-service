package com.bleurubin.budgetanalyzer.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotNull;

import io.swagger.v3.oas.annotations.media.Schema;

import com.bleurubin.core.domain.SoftDeletableEntity;

/** Transaction entity representing a financial transaction. */
@Entity
@Schema(description = "Transaction entity representing a financial transaction")
public class Transaction extends SoftDeletableEntity {

  /** Unique identifier for the transaction. */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Schema(
      description = "Unique identifier for the transaction",
      requiredMode = Schema.RequiredMode.REQUIRED,
      example = "1")
  private Long id;

  /** Identifier for the account associated with the transaction. */
  @Schema(
      description = "Identifier for the account associated with the transaction",
      requiredMode = Schema.RequiredMode.NOT_REQUIRED,
      example = "checking-3223")
  private String accountId;

  /** Name of the bank where the transaction occurred. */
  @NotNull
  @Schema(
      description = "Name of the bank where the transaction occurred",
      requiredMode = Schema.RequiredMode.REQUIRED,
      example = "Capital One")
  private String bankName;

  /** Date of the transaction. */
  @NotNull
  @Schema(
      description = "Date of the transaction",
      requiredMode = Schema.RequiredMode.REQUIRED,
      example = "2025-10-14")
  private LocalDate date;

  /** ISO currency code for the transaction. */
  @NotNull
  @Schema(
      description = "ISO currency code for the transaction",
      requiredMode = Schema.RequiredMode.REQUIRED,
      example = "USD")
  private String currencyIsoCode;

  /** Amount of the transaction. */
  @NotNull
  @Schema(
      description = "Amount of the transaction",
      requiredMode = Schema.RequiredMode.REQUIRED,
      example = "100.50")
  private BigDecimal amount;

  /** Type of the transaction (e.g., DEBIT, CREDIT). */
  @Enumerated(EnumType.STRING)
  @NotNull
  @Schema(
      description = "Type of the transaction",
      requiredMode = Schema.RequiredMode.REQUIRED,
      allowableValues = {"CREDIT", "DEBIT"},
      example = "DEBIT")
  private TransactionType type;

  /** Description of the transaction. */
  @NotNull
  @Schema(
      description = "Description of the transaction",
      requiredMode = Schema.RequiredMode.REQUIRED,
      example = "Grocery shopping")
  private String description;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getAccountId() {
    return accountId;
  }

  public void setAccountId(String accountId) {
    this.accountId = accountId;
  }

  public String getBankName() {
    return bankName;
  }

  public void setBankName(String bankName) {
    this.bankName = bankName;
  }

  public LocalDate getDate() {
    return date;
  }

  public void setDate(LocalDate date) {
    this.date = date;
  }

  public String getCurrencyIsoCode() {
    return currencyIsoCode;
  }

  public void setCurrencyIsoCode(String currencyIsoCode) {
    this.currencyIsoCode = currencyIsoCode;
  }

  public BigDecimal getAmount() {
    return amount;
  }

  public void setAmount(BigDecimal amount) {
    this.amount = amount;
  }

  public TransactionType getType() {
    return type;
  }

  public void setType(TransactionType type) {
    this.type = type;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }
}
