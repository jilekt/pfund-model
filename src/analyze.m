clear

% === CONFIG ===
yr_count = 34;
test1.type = 1;  % 1..user-defined, 2..all-combinations
SAVE_FIGS = 1;

% === PRESETS ===
test1.bf.user = [100; 500; 1000; 1500; 2000; 2500; 3000; 3500];  % [CZK]
test1.bf.empl = [0, 600];  % [CZK]
test1.bf.p    = [0; 1];    % [%]

test1.ud.params = [100,   0, 1  % user_monthly, employer_monthly, percent
                   500,   0, 1
                   500,   0, 0
                   100, 600, 1
                   300, 600, 1
                   500, 600, 1
                  1000, 600, 1
                  1500, 600, 1
                  2000, 600, 1
                  2500, 600, 1
                  3000, 600, 1
                  3500, 600, 1];

test2.user_step = 100;  % [CZK]
test2.user_steps_count = fix(3500 / test2.user_step);
test2.empl = 0;  % [CZK]
test2.p    = 0;  % [%]

test3.user = 500;
test3.empl = 600;
test3.p    = 1;

% === PROCESSING ===

% generate test vectors
switch test1.type
    case 1  % user-defined
        test1.params = test1.ud.params;

    case 2  % all-combinations
        test1.params = [];
        for k = 1:length(test1.bf.p)
            for j = 1:length(test1.bf.empl)
                for i = 1:length(test1.bf.user)
                    test1.params(end + 1, :) = [test1.bf.user(i), test1.bf.empl(j), test1.bf.p(k)];
                end
            end
        end
end

% pension fund in different scenarios
for i = 1:size(test1.params, 1)
    data1(i) = pfund(test1.params(i, 1), test1.params(i, 2), test1.params(i, 3), yr_count);
    results1.pa_long(:, i) = equalpa(data1(i).yr_sum.user, data1(i).yr_csum.total);
    results1.total(:, i) = data1(i).yr_csum.total;
    legend1{i} = [data1(i).info, sprintf(' [%.2f | %.2f %%]', results1.pa_long(15, i), results1.pa_long(end, i))];
end

% pension fund for different user amounts
for i = 1:test2.user_steps_count
    data2(i) = pfund(test2.user_step * i, test2.empl, test2.p, yr_count);
    results2.total(:, i) = data2(i).yr_csum.total;
    results2.user(:, i) = data2(i).yr_sum.user;
end

results2.dtotal = results2.total - [zeros(size(results2.total, 1), 1), results2.total(:, 1:end-1)];
results2.duser  = results2.user  - [zeros(size(results2.user, 1), 1),  results2.user(:, 1:end-1)];

for i = 1:test2.user_steps_count
    results2.pa_short(:, i) = (data2(i).yr_sum.total - data2(i).yr_sum.user) ./ ([0; data2(i).yr_csum.total(1:end-1)] + 0.5 * data2(i).yr_sum.user) * 100;
    results2.pa_short_d(:, i) = (diff([0; results2.dtotal(:, i)]) - results2.duser(:, i)) ./ ([0; results2.dtotal(1:end-1, i)] + 0.5 * results2.duser(:, i)) * 100;
    results2.pa_long(:, i) = equalpa(data2(i).yr_sum.user, data2(i).yr_csum.total);
    results2.pa_long_d(:, i) = equalpa(results2.duser(:, i), results2.dtotal(:, i));
    legend2_short{i} = sprintf('%.0f CZK [%.2f | %.2f %%]', i * test2.user_step, results2.pa_short(15, i), results2.pa_short(end, i));
    legend2_short_d{i} = sprintf('%.0f - %.0f CZK [%.2f | %.2f %%]', (i-1) * test2.user_step + 1, i * test2.user_step, results2.pa_short_d(15, i), results2.pa_short_d(end, i));
    legend2_long{i} = sprintf('%.0f CZK [%.2f | %.2f %%]', i * test2.user_step, results2.pa_long(15, i), results2.pa_long(end, i));
    legend2_long_d{i} = sprintf('%.0f - %.0f CZK [%.2f | %.2f %%]', (i-1) * test2.user_step + 1, i * test2.user_step, results2.pa_long_d(15, i), results2.pa_long_d(end, i));
end

% comparison with classic account type (verification only)
data3_pf = pfund(test3.user, test3.empl, test3.p, yr_count);
results3.pa_long(:, 1) = equalpa(data3_pf.yr_sum.user, data3_pf.yr_csum.total);
data3_a = account(data3_pf.yr_sum.user / 12, results3.pa_long(end) / 0.85, yr_count);

% === FILE OUTPUT ===

% test for '../results' folder, if not exist, create it
if exist('../results', 'dir') ~= 7
    mkdir('../results');
end

% save results #1 to file
fid = fopen('../results/results-1-long', 'wt');
fprintf(fid, ['user:',    repmat('\t%.0f',     1, size(test1.params, 1)), '\n'], test1.params(:, 1));
fprintf(fid, ['empl:',    repmat('\t%.0f',     1, size(test1.params, 1)), '\n'], test1.params(:, 2));
fprintf(fid, ['p:',       repmat('\t%.2f',     1, size(test1.params, 1)), '\n'], test1.params(:, 3));
fprintf(fid, ['========', repmat('========',   1, size(test1.params, 1)), '\n']);
fprintf(fid, ['year',     repmat('\tp.a.[%%]', 1, size(test1.params, 1)), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, size(test1.params, 1)), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.2f',     1, size(test1.params, 1)), '\n'], [data1(1).years, results1.pa_long].');
fprintf(fid, ['========', repmat('========',   1, size(test1.params, 1)), '\n']);
fprintf(fid, ['year',     repmat('\tttl [k]',  1, size(test1.params, 1)), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, size(test1.params, 1)), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.1f',     1, size(test1.params, 1)), '\n'], [data1(1).years, results1.total / 1000].');
fclose(fid);

% save results #2a to file
fid = fopen('../results/results-2-short', 'wt');
fprintf(fid, ['user:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], (1:test2.user_steps_count) * test2.user_step);
fprintf(fid, ['empl:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.empl);
fprintf(fid, ['p:',       repmat('\t%.2f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.p);
fprintf(fid, ['========', repmat('========',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['year',     repmat('\tp.a.[%%]', 1, test2.user_steps_count), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.2f',     1, test2.user_steps_count), '\n'], [data2(1).years, results2.pa_short].');
fclose(fid);

% save results #2b to file
fid = fopen('../results/results-3-long', 'wt');
fprintf(fid, ['user:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], (1:test2.user_steps_count) * test2.user_step);
fprintf(fid, ['empl:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.empl);
fprintf(fid, ['p:',       repmat('\t%.2f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.p);
fprintf(fid, ['========', repmat('========',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['year',     repmat('\tp.a.[%%]', 1, test2.user_steps_count), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.2f',     1, test2.user_steps_count), '\n'], [data2(1).years, results2.pa_long].');
fclose(fid);

% save results #2c to file
fid = fopen('../results/results-4-short-diff', 'wt');
fprintf(fid, ['user:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], (1:test2.user_steps_count) * test2.user_step);
fprintf(fid, ['empl:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.empl);
fprintf(fid, ['p:',       repmat('\t%.2f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.p);
fprintf(fid, ['========', repmat('========',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['year',     repmat('\tp.a.[%%]', 1, test2.user_steps_count), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.2f',     1, test2.user_steps_count), '\n'], [data2(1).years, results2.pa_short_d].');
fclose(fid);

% save results #2d to file
fid = fopen('../results/results-5-long-diff', 'wt');
fprintf(fid, ['user:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], (1:test2.user_steps_count) * test2.user_step);
fprintf(fid, ['empl:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.empl);
fprintf(fid, ['p:',       repmat('\t%.2f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.p);
fprintf(fid, ['========', repmat('========',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['year',     repmat('\tp.a.[%%]', 1, test2.user_steps_count), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.2f',     1, test2.user_steps_count), '\n'], [data2(1).years, results2.pa_long_d].');
fclose(fid);

% === GRAPHS ===

% pension fund in different scenarios
figure(1)
clf

colors = 'brgmck';
for i = 1:size(test1.params, 1)
    plot(data1(i).years, results1.pa_long(:, i), colors(1 + rem(i - 1, length(colors))), 'linewidth', 2)
    hold on
end
grid on
xlabel('#year')
ylabel('long-term p.a. [%]')
title('equivalent long-term p.a. in different scenarios')
legend(legend1)

% pension fund for different user amount - short-term p.a.
figure(2)
clf

plot(data2(1).years, results2.pa_short, 'linewidth', 2)
grid on
xlabel('#year')
ylabel('short-term p.a. [%]')
title(sprintf('equivalent short-term p.a. [u: %.0f - %.0f CZK | e: %.0f CZK | p: %.1f %%]', test2.user_step, test2.user_step * test2.user_steps_count, test2.empl, test2.p))
legend(legend2_short)

% pension fund for different user amount - long-term p.a.
figure(3)
clf

plot(data2(1).years, results2.pa_long, 'linewidth', 2)
grid on
xlabel('#year')
ylabel('long-term p.a. [%]')
title(sprintf('equivalent long-term p.a. [u: %.0f - %.0f CZK | e: %.0f CZK | p: %.1f %%]', test2.user_step, test2.user_step * test2.user_steps_count, test2.empl, test2.p))
legend(legend2_long)

% pension fund for different user amount - short-term p.a. diff. analysis
figure(4)
clf

plot(data2(1).years, results2.pa_short_d, 'linewidth', 2)
grid on
xlabel('#year')
ylabel('short-term p.a. [%]')
title(sprintf('equivalent short-term p.a. for every %.0f CZK [u: %.0f - %.0f CZK | e: %.0f CZK | p: %.1f %%]', test2.user_step, test2.user_step, test2.user_step * test2.user_steps_count, test2.empl, test2.p))
legend(legend2_short_d)

% pension fund for different user amount - long-term p.a. diff. analysis
figure(5)
clf

plot(data2(1).years, results2.pa_long_d, 'linewidth', 2)
grid on
xlabel('#year')
ylabel('long-term p.a. [%]')
title(sprintf('equivalent long-term p.a. for every %.0f CZK [u: %.0f - %.0f CZK | e: %.0f CZK | p: %.1f %%]', test2.user_step, test2.user_step, test2.user_step * test2.user_steps_count, test2.empl, test2.p))
legend(legend2_long_d)

% comparison with classic account type (verification only)
figure(6)
clf

plot(data3_pf.years, data3_pf.yr_csum.total, 'b')
hold on
plot(data3_a.years,  data3_a.yr_csum.total,  'r')
grid on
xlabel('#year')
ylabel('total amount [CZK]')
title('total amount @ year')
legend(sprintf('pension fund (u: %.0f, e: %.0f, p: %.2f %%)', test3.user, test3.empl, test3.p), sprintf('account (u: %.0f, p: %.2f %%)', data3_pf.yr_sum.user(1) / 12, results3.pa_long(end) / 0.85))

% year sum in years
figure(7)
clf

bar(data3_pf.years, [data3_pf.yr_sum.user, data3_pf.yr_sum.empl, data3_pf.yr_sum.gov, data3_pf.yr_sum.tax, data3_pf.yr_sum.add], 'stacked')
grid on
xlabel('#year')
ylabel('amount [CZK]')
title(['year sum @ year [', data3_pf.info, ']'])
legend('user', 'employer', 'government', 'tax discount', 'addition')

% year cumulative sum in years
figure(8)
clf

bar(data3_pf.years, [data3_pf.yr_csum.user, data3_pf.yr_csum.empl, data3_pf.yr_csum.gov, data3_pf.yr_csum.tax, data3_pf.yr_csum.add], 'stacked')
grid on
xlabel('#year')
ylabel('total amount [CZK]')
title(['year cumulative sum @ year [', data3_pf.info, ']'])
legend('user', 'employer', 'government', 'tax discount', 'addition')

if SAVE_FIGS
    for i = 1:8
       print(i, sprintf('../results/fig-%.0f.png', i), '-dpng', '-r300')
    end
end
