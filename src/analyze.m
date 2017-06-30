clear

% === CONFIG ===
yr_count = 34;
test1_type = 1; % 1..user-defined, 2..brutal-force

% === PRESETS ===
test1.bf.user = [100; 500; 1000; 1500; 2000; 2500; 3000; 3500];  % [CZK]
test1.bf.empl = [0, 600];  % [CZK]
test1.bf.p    = [0; 1];    % [%]

test1.params_ud = [100,   0, 1  % user_monthly, employer_monthly, percent
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

test2.user_step = 100;
test2.user_steps_count = fix(3500 / test2.user_step);
test2.empl = 600;  % [CZK]
test2.p    = 0;    % [%]

test3.user = 500;
test3.empl = 600;
test3.p    = 1;

% === PROCESSING ===

% generate test vectors
switch test1_type
    case 1  % user-defined
        test1.params = test1.params_ud;

    case 2  % brutal-force
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
    results1.pa_eq(:, i) = equalpa(data1(i).amounts.user_eff, data1(i).cumsum.total);
    results1.total(:, i) = data1(i).cumsum.total;
    legend1{i} = [data1(i).info, sprintf(' [%.2f | %.2f %%]', results1.pa_eq(15, i), results1.pa_eq(end, i))];
end

% differential analysis
for i = 1:test2.user_steps_count
    data2(i) = pfund(test2.user_step * i, test2.empl, test2.p, yr_count);
    results2.total(:, i) = data2(i).cumsum.total;
    results2.user_eff(:, i) = data2(i).amounts.user_eff;
end

results2.dtotal = results2.total - [zeros(size(results2.total, 1), 1), results2.total(:, 1:end-1)];
results2.duser_eff = results2.user_eff - [zeros(size(results2.user_eff, 1), 1), results2.user_eff(:, 1:end-1)];

for i = 1:test2.user_steps_count
    results2.pa_eq(:, i) = equalpa(results2.duser_eff(:, i), results2.dtotal(:, i));
    legend2{i} = sprintf('%.0f - %.0f CZK [%.2f | %.2f %%]', (i-1) * test2.user_step + 1, i * test2.user_step, results2.pa_eq(15, i), results2.pa_eq(end, i));
end

% comparison with classic account type (verification only)
data3_pf = pfund(test3.user, test3.empl, test3.p, yr_count);
results3.pa_eq(:, 1) = equalpa(data3_pf.amounts.user_eff, data3_pf.cumsum.total);
data3_a = account(data3_pf.amounts.user_eff / 12, results3.pa_eq(end) / 0.85, yr_count);

% === FILE OUTPUT ===

% test for '../results' folder, if not exist, create it
if exist('../results', 'dir') ~= 7
    mkdir('../results');
end

% save results #1 to file
fid = fopen('../results/result-1', 'wt');
fprintf(fid, ['user:',    repmat('\t%.0f',     1, size(test1.params, 1)), '\n'], test1.params(:, 1));
fprintf(fid, ['empl:',    repmat('\t%.0f',     1, size(test1.params, 1)), '\n'], test1.params(:, 2));
fprintf(fid, ['p:',       repmat('\t%.2f',     1, size(test1.params, 1)), '\n'], test1.params(:, 3));
fprintf(fid, ['========', repmat('========',   1, size(test1.params, 1)), '\n']);
fprintf(fid, ['year',     repmat('\tp.a.[%%]', 1, size(test1.params, 1)), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, size(test1.params, 1)), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.2f',     1, size(test1.params, 1)), '\n'], [data1(1).years, results1.pa_eq].');
fprintf(fid, ['========', repmat('========',   1, size(test1.params, 1)), '\n']);
fprintf(fid, ['year',     repmat('\tttl [k]',  1, size(test1.params, 1)), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, size(test1.params, 1)), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.1f',     1, size(test1.params, 1)), '\n'], [data1(1).years, results1.total / 1000].');
fclose(fid);

% save results #2 to file
fid = fopen('../results/result-2', 'wt');
fprintf(fid, ['user:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], (1:test2.user_steps_count) * test2.user_step);
fprintf(fid, ['empl:',    repmat('\t%.0f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.empl);
fprintf(fid, ['p:',       repmat('\t%.2f',     1, test2.user_steps_count), '\n'], ones(test2.user_steps_count, 1) * test2.p);
fprintf(fid, ['========', repmat('========',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['year',     repmat('\tp.a.[%%]', 1, test2.user_steps_count), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.2f',     1, test2.user_steps_count), '\n'], [data2(1).years, results2.pa_eq].');
fprintf(fid, ['========', repmat('========',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['year',     repmat('\tttl [k]',  1, test2.user_steps_count), '\n']);
fprintf(fid, ['--------', repmat('--------',   1, test2.user_steps_count), '\n']);
fprintf(fid, ['%.0f',     repmat('\t%.1f',     1, test2.user_steps_count), '\n'], [data2(1).years, results2.total / 1000].');
fclose(fid);

% === GRAPHS ===

% pension fund in different scenarios
figure(1)
clf

colors = 'brgmck';
for i = 1:size(test1.params, 1)
    plot(data1(i).years, results1.pa_eq(:, i), colors(1 + rem(i - 1, length(colors))), 'linewidth', 2)
    hold on
end
grid on
xlabel('#year')
ylabel('long-term p.a. [%]')
title('equivalent long-term p.a. in different scenarios')
legend(legend1)

% differential analysis
figure(2)
clf

plot(data2(1).years, results2.pa_eq, 'linewidth', 2)
grid on
xlabel('#year')
ylabel('long-term p.a. [%]')
title(sprintf('equivalent long-term p.a. for every %.0f CZK [u: %.0f - %.0f CZK | e: %.0f CZK | p: %.1f %%]', test2.user_step, test2.user_step, test2.user_step * test2.user_steps_count, test2.empl, test2.p))
legend(legend2)

% comparison with classic account type (verification only)
figure(3)
clf

plot(data3_pf.years, data3_pf.cumsum.total, 'b')
hold on
plot(data3_a.years,  data3_a.cumsum.total,  'r')
grid on
xlabel('#year')
ylabel('total amount [CZK]')
title('amount-total @ year')
legend(sprintf('pension fund (u: %.0f, e: %.0f, p: %.2f %%)', test3.user, test3.empl, test3.p), sprintf('account (u: %.0f, p: %.2f %%)', data3_pf.amounts.user_eff(1) / 12, results3.pa_eq(end) / 0.85))
