function data = pfund(amount_user, amount_empl, p, years_count)
% implemented: user, employer, government, tax discount (~user_eff), p
% taxes: employer (15 %), p (15 %)
% valid for year 2017

% compute government benefit and tax discount
if amount_user < 100
    error('user monthly amount is too low!')
elseif amount_user < 300
    amount_gov = 0;
    amount_tax = 0;
elseif amount_user < 1000
    amount_gov = 90 + 0.2 * (amount_user - 300);
    amount_tax = 0;
elseif amount_user < 3000
    amount_gov = 230;
    amount_tax = (amount_user - 1000) * 0.15;
else
    amount_gov = 230;
    amount_tax = 300;
end

data.years = (1:years_count).';

data.amounts.user = ones(years_count, 1) * 12 * amount_user;
data.amounts.empl = ones(years_count, 1) * 12 * amount_empl * 0.85;
data.amounts.gov  = ones(years_count, 1) * 12 * amount_gov;
data.amounts.tax  = ones(years_count, 1) * 12 * amount_tax;
data.amounts.all  = data.amounts.user + data.amounts.empl + data.amounts.gov;
data.amounts.user_eff = data.amounts.user - data.amounts.tax;

data.cumsum.user = cumsum(data.amounts.user);
data.cumsum.empl = cumsum(data.amounts.empl);
data.cumsum.gov  = cumsum(data.amounts.gov);
data.cumsum.tax  = cumsum(data.amounts.tax);
data.cumsum.all  = data.cumsum.user + data.cumsum.empl + data.cumsum.gov;
data.cumsum.user_eff = data.cumsum.user - data.cumsum.tax;

data.cumsum.total = zeros(years_count, 1);
data.cumsum.total(1) = data.cumsum.all(1) * (1 + 0.01 * p * 0.85);
for year = 2:years_count
    data.cumsum.total(year) = (data.cumsum.total(year-1) + data.amounts.all(year)) * (1 + 0.01 * p * 0.85);
end

data.info = sprintf('u: %.0f, e: %.0f, g: %.0f, t: %.0f, p: %.1f', amount_user, amount_empl, amount_gov, amount_tax, p);

end
