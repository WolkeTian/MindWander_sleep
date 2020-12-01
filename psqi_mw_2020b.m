clear;clc;close;

%% load beh data
contents = readtable('华大项目睡眠组数据概览_完整版0813.xlsx', 'Sheet', '757');
beh_table = contents(1:end, :);

beh_subid = str2double(beh_table{:,1}); % 提取被试编号
psqi = beh_table{:,2};
mwscores = beh_table{:,14}; % mw量表总分
%% load fnc
fncdir = 'ConnMatrix.mat';
load(fncdir);
fnc_subid = str2double(cellfun(@(x) x(4:end), sub_valid, 'UniformOutput', false));

%% find matched subject number
[matched_id, beh_order, fnc_order] = intersect(beh_subid, fnc_subid); % 756个匹配的人

%% cal mw corr with fnc
mw_scores = mwscores(beh_order);
fnc_mat = permute(ConnMatrix(:,:,fnc_order), [3,1,2]); % permute to sub*264*264
[h_mw,p_mw] = corr(mw_scores, reshape(fnc_mat, size(fnc_mat,1), size(fnc_mat,2)^2));
[h_mw,p_mw] = deal(reshape(h_mw, size(fnc_mat,2), size(fnc_mat,2)), reshape(p_mw, size(fnc_mat,2), size(fnc_mat,2)));

mw_fdr = conn_fdr(p_mw);
[a_mw,b_mw] = find(mw_fdr<0.05);

%% cal psqi corr with fnc
psqi_scores = psqi(beh_order);

[h_psqi,p_psqi] = corr(psqi_scores, reshape(fnc_mat, size(fnc_mat,1), size(fnc_mat,2)^2));
[h_psqi,p_psqi] = deal(reshape(h_psqi, size(fnc_mat,2), size(fnc_mat,2)), reshape(p_psqi, size(fnc_mat,2), size(fnc_mat,2)));
 % 转回264*264
psqi_fdr = conn_fdr(p_psqi);
[a_psqi,b_psqi] = find(psqi_fdr<0.05);

%% find matched links after fdr
% [a_matched, b_matched] = find((mw_fdr<0.05) .* (psqi_fdr<0.05) == 1);
% fdr 后 没有重合的结果
%% find matched links no fdr
[a_matched, b_matched] = find((p_mw<0.01) .* (p_psqi<0.01) == 1);
 % h_mw((p_mw<0.01) .* (p_psqi<0.01) == 1) .* h_psqi((p_mw<0.01) .* (p_psqi<0.01) == 1)
 % 正负方向一致，就是和mw正相关的也是和psqi正相关，负相关同

 %% find target fnc values for pos and neg
 matched_link = tril((p_mw<0.01) .* (p_psqi<0.01) == 1, -1); % 保留下三角
 pos_link = h_mw.*matched_link > 0; % 5条正连接, 264*264的逻辑矩阵
 neg_link = h_mw.*matched_link < 0; % 5条负连接
 
 % extract h and p value for these links
 h_psqi(pos_link); p_psqi(pos_link);
 
 
 %
 fnc_pos = fnc_mat(:, pos_link); % 提取与psqi&mw均正相关的个体连接，下类似
 fnc_neg = fnc_mat(:,neg_link);
 
 %% extract mean pos link fnc values & neg link fnc values as mediators
 
 mediator_pos = mean(fnc_pos, 2);
 mediator_neg = mean(fnc_neg, 2);
 
 %% test whether corr with mw and psqi
 % 正相关的连接，平均后与psqi显著相关，0.1976，与mw0.2306
 % 负相关的连接，平均后与psqi显著相关，-0.2107, 与mw -0.2148
 [h_test, p_test] = corr(mediator_pos, psqi_scores); %
 
 %% save to table
 %两个模型一正一负，中介都非常显著
 mindwander = table(psqi_scores, mw_scores, mediator_pos, mediator_neg);
 writetable(mindwander, 'modelInput.csv');
 
 %% find link's name and networks
 load powerInfo
 [a,b] = find(pos_link == 1);
 pos_net1 = powerNet(a);pos_net2 = powerNet(b);
 pos_MNI1 = powerMNI(a, :); pos_MNI2 = powerMNI(b, :);
 label1 = cuixuFindStructure(pos_MNI1); label2 = cuixuFindStructure(pos_MNI2);

 
 % neg links
 [a,b] = find(neg_link == 1);
 neg_net1 = powerNet(a);neg_net2 = powerNet(b);
 neg_MNI1 = powerMNI(a, :); neg_MNI2 = powerMNI(b, :);
 label3 = cuixuFindStructure(neg_MNI1); label4 = cuixuFindStructure(neg_MNI2);
 
 %% results
 temp1 = cellfun(@(x)strsplit(x, '//'), label1, 'UniformOutput', false);
 temp2 = cellfun(@(x) x(end), temp1, 'UniformOutput', false);
%  postive links
%  {' Precentral_R (aal)';' Angular_L (aal)';' Parietal_Sup_L (aal)';' Cingulum_Ant_L (aal)';' Temporal_Inf_R (aal)'}
%  {' Occipital_Inf_L (aal)';' Postcentral_R (aal)';' Precentral_R (aal)';' Insula_R (aal)';' Precuneus_R (aal)'}
%  negtive links
%  {' Frontal_Inf_Tri_R (aal)';' Postcentral_R (aal)';' Putamen_R (aal)';'Thalamus_R(aal)';' Parietal_Inf_L (aal)'}
%  {' Rectus_R (aal)';' Paracentral_Lobule_L (aal)';' Occipital_Mid_L (aal)';' Cuneus_L (aal)';' Cingulum_Ant_R (aal)'}

