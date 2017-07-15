function data = pfund(amount_user, amount_empl, p, yr_count)
% implemented: user, employer, government, tax discount, p
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

data.years = (1:yr_count).';

data.yr_sum.empl = ones(yr_count, 1) * 12 * amount_empl * 0.85;  % tax 15 %
data.yr_sum.gov  = ones(yr_count, 1) * 12 * amount_gov;
data.yr_sum.tax  = ones(yr_count, 1) * 12 * amount_tax;
data.yr_sum.user = ones(yr_count, 1) * 12 * amount_user - data.yr_sum.tax;
data.yr_sum.all  = data.yr_sum.user + data.yr_sum.empl + data.yr_sum.gov + data.yr_sum.tax;

data.yr_csum.user = cumsum(data.yr_sum.user);
data.yr_csum.empl = cumsum(data.yr_sum.empl);
data.yr_csum.gov  = cumsum(data.yr_sum.gov);
data.yr_csum.tax  = cumsum(data.yr_sum.tax);
data.yr_csum.all  = cumsum(data.yr_sum.all);

data.yr_csum.total = zeros(yr_count, 1);
data.yr_csum.total(1) = data.yr_csum.all(1) * (1 + 0.5 * p / 100 * 0.85);  % tax 15 %
for year = 2:yr_count
    data.yr_csum.total(year) = data.yr_csum.total(year-1) + data.yr_sum.all(year) + (data.yr_csum.total(year-1) + 0.5 * data.yr_sum.all(year)) * p / 100 * 0.85;  % tax 15 %
end

data.yr_csum.add = data.yr_csum.total - data.yr_csum.all;
data.yr_sum.add = diff([0; data.yr_csum.add]);
data.yr_sum.total = diff([0; data.yr_csum.total]);

data.info = sprintf('u: %.0f, e: %.0f, g: %.0f, t: %.0f, p: %.1f', amount_user, amount_empl, amount_gov, amount_tax, p);

end
