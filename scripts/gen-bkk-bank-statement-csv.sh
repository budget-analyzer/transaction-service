#!/bin/bash

set -euo pipefail

# Script to generate BKK Bank CSV files with random transactions
# Usage: ./gen-bkk-bank-csv.sh START_DATE END_DATE
# Date format: YYYY-MM-DD

readonly SCRIPT_NAME=$(basename "$0")

# Transaction particulars for withdrawals
readonly WITHDRAWAL_PARTICULARS=(
    "TRF. PROMPTPAY"
    "CASH ATM W/D"
    "FEE OTH BAK ATM"
    "PMT. PROMPTPAY"
    "DEBIT CARD PURCHASE"
    "ONLINE PAYMENT"
    "BILL PAYMENT"
    "TRANSFER OUT"
    "CASH WITHDRAWAL"
    "SERVICE FEE"
    "INTERNATIONAL TRANSFER"
    "LOAN PAYMENT"
)

# Transaction particulars for deposits
readonly DEPOSIT_PARTICULARS=(
    "CREDIT"
    "FOREIGN T/T"
    "SALARY TRANSFER"
    "DIRECT DEPOSIT"
    "TRANSFER IN"
    "CASH DEPOSIT"
    "MOBILE DEPOSIT"
    "WIRE TRANSFER"
    "REFUND"
    "INTEREST CREDIT"
)

# Via channels
readonly VIA_CHANNELS=(
    "mPhone"
    "Auto"
    "ATMoth"
    "Branch"
    "Internet"
    "Mobile"
)

usage() {
    cat << EOF
Usage: $SCRIPT_NAME START_DATE END_DATE

Generate a BKK Bank CSV file with random transactions.

Arguments:
    START_DATE    Start date in YYYY-MM-DD format
    END_DATE      End date in YYYY-MM-DD format

Example:
    $SCRIPT_NAME 2024-01-01 2024-12-31

EOF
    exit 1
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

validate_date() {
    local date_str="$1"
    if ! date -d "$date_str" &>/dev/null; then
        error_exit "Invalid date format: $date_str. Expected YYYY-MM-DD"
    fi
}

date_to_epoch() {
    date -d "$1" +%s
}

epoch_to_ddmmyy() {
    date -d "@$1" +%d/%m/%y
}

random_amount() {
    local min="$1"
    local max="$2"
    # Generate random amount with 2 decimal places
    echo "$(awk -v min="$min" -v max="$max" 'BEGIN{srand(); printf "%.2f\n", min + rand() * (max - min)}')"
}

format_amount() {
    local amount="$1"
    # Format number with comma thousands separator
    # First format to 2 decimal places, then add commas
    local formatted=$(printf "%.2f" "$amount")
    # Add comma separators for thousands
    echo "$formatted" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'
}

random_balance() {
    # Generate a random balance between 10000 and 200000
    echo "$(awk 'BEGIN{srand(); printf "%.2f\n", 10000 + rand() * 190000}')"
}

get_random_particular() {
    local type="$1"
    if [[ "$type" == "withdrawal" ]]; then
        local idx=$((RANDOM % ${#WITHDRAWAL_PARTICULARS[@]}))
        echo "${WITHDRAWAL_PARTICULARS[$idx]}"
    else
        local idx=$((RANDOM % ${#DEPOSIT_PARTICULARS[@]}))
        echo "${DEPOSIT_PARTICULARS[$idx]}"
    fi
}

get_random_via() {
    local idx=$((RANDOM % ${#VIA_CHANNELS[@]}))
    echo "${VIA_CHANNELS[$idx]}"
}

generate_transactions() {
    local start_epoch="$1"
    local end_epoch="$2"
    local date_range=$((end_epoch - start_epoch))
    local num_days=$((date_range / 86400))
    
    # Generate 1-2 transactions per day on average
    local avg_days_between=1
    local num_transactions=$((num_days / avg_days_between))
    
    # Ensure at least a few transactions
    if [[ $num_transactions -lt 5 ]]; then
        num_transactions=5
    fi
    
    # Starting balance
    local balance=$(random_balance)
    
    # Generate random transactions
    declare -a transactions=()
    for ((i=0; i<num_transactions; i++)); do
        # Random timestamp within range using awk for better randomness
        local random_offset=$(awk -v range=$date_range 'BEGIN{srand(); print int(rand() * range)}')
        local transaction_epoch=$((start_epoch + random_offset))
        local transaction_date=$(epoch_to_ddmmyy "$transaction_epoch")
        
        # 60% chance of withdrawal, 40% chance of deposit
        local transaction_type="withdrawal"
        if [[ $((RANDOM % 10)) -lt 4 ]]; then
            transaction_type="deposit"
        fi
        
        local particular=$(get_random_particular "$transaction_type")
        local via=$(get_random_via)
        
        # Generate appropriate amounts based on transaction type
        local amount
        if [[ "$transaction_type" == "withdrawal" ]]; then
            # Withdrawals: 10 - 15000
            amount=$(random_amount 10 15000)
        else
            # Deposits: 500 - 150000
            amount=$(random_amount 500 150000)
        fi
        
        local formatted_amount=$(format_amount "$amount")
        
        # Calculate new balance
        if [[ "$transaction_type" == "withdrawal" ]]; then
            balance=$(awk -v bal="$balance" -v amt="$amount" 'BEGIN{printf "%.2f", bal - amt}')
        else
            balance=$(awk -v bal="$balance" -v amt="$amount" 'BEGIN{printf "%.2f", bal + amt}')
        fi
        
        local formatted_balance=$(format_amount "$balance")
        
        # Build CSV line based on transaction type
        local withdrawal_col=""
        local deposit_col=""
        
        if [[ "$transaction_type" == "withdrawal" ]]; then
            withdrawal_col="\"$formatted_amount\""
        else
            deposit_col="\"$formatted_amount\""
        fi
        
        # Store as CSV line with epoch for sorting
        # Format: Date,Particulars,Withdrawal,Deposit,Balance,Via
        transactions+=("$transaction_epoch|$transaction_date,$particular,$withdrawal_col,$deposit_col,\"$formatted_balance\",$via")
    done
    
    # Sort transactions by date (epoch timestamp)
    printf '%s\n' "${transactions[@]}" | sort -t'|' -k1 -n | cut -d'|' -f2
}

main() {
    # Validate arguments
    if [[ $# -ne 2 ]]; then
        usage
    fi
    
    local start_date="$1"
    local end_date="$2"
    
    # Validate date formats
    validate_date "$start_date"
    validate_date "$end_date"
    
    # Convert to epoch timestamps
    local start_epoch=$(date_to_epoch "$start_date")
    local end_epoch=$(date_to_epoch "$end_date")
    
    # Validate date range
    if [[ $start_epoch -ge $end_epoch ]]; then
        error_exit "Start date must be before end date"
    fi
    
    # Generate output filename
    local output_file="bkk-bank-statement-${start_date}-to-${end_date}.csv"
    
    # Generate CSV
    echo "Generating transactions from $start_date to $end_date..."
    
    {
        # Header row
        echo "Date,Particulars,Withdrawal,Deposit,Balance,Via"
        
        # Generate and output transactions
        generate_transactions "$start_epoch" "$end_epoch"
    } > "$output_file"
    
    local num_transactions=$(($(wc -l < "$output_file") - 1))
    echo "Generated $num_transactions transactions in $output_file"
}

main "$@"
