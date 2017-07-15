function data = account(amount_monthly, p, yr_count)

if length(amount_monthly) == 1
    amount_yearly = 12 * amount_monthly * ones(years_count, 1);
else
    amount_yearly = 12 * amount_monthly;
end

data.years = (1:yr_count).';
data.yr_csum.total = zeros(yr_count, 1);
data.yr_csum.total(1) = amount_yearly(1) * (1 + 0.5 * p / 100 * 0.85);  % tax: 15 %
for year = 2:yr_count
    data.yr_csum.total(year) = data.yr_csum.total(year-1) + amount_yearly(year) + (data.yr_csum.total(year-1) + 0.5 * amount_yearly(year)) * p / 100 * 0.85;  % tax: 15 %
end

end
