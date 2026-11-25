# Phase 1 · Layer-B 综合（截至 R11，含 OpenAlex 补检）

> 每条判断回引 `records.jsonl` 的 Layer-A 记录 id。检查方式：抽样重读被引记录及其 `evidence_quote + location`。
> R1–R10 为主调研，R11 为 OpenAlex 恢复后的补充复核（0 个 A/B/C 命中，但 `2610.03025` 使两条辅助新颖性主张失效）。最终门裁定见 `exit-eval.md`。

---

## 0. 裁决摘要

| 主张 | 新颖性 | 真值 | 裁决 |
|---|---|---|---|
| **P1(a)** single-rub 对 golden-rub 覆盖率显著 <1 | **已死**：≥6 个独立测量在同构念下给出 | 强烈支持 | 只能作为已确立前提引用，不能再作贡献 |
| **P1(b)** 不同 single-rub 覆盖之间重叠低 | **仍活**：无人计算跨模型漏集/覆盖集的重合 | 未测 | 可作为测量贡献 |
| **P1 系统性** 遗漏是系统性的（同一批侧面被漏） | **仍活，但测量形态被部分占先**：`2610.03025` 已用 capture–recapture 把"未被发现的准则值多少钱"做成可界定量 | 间接支持 | 贡献必须限定为"**跨 LLM backbone 的漏集重合**（φ/Jaccard vs 独立性零模型）+ **专家 golden-rub 参照**"；不能主张"首个把覆盖不完备做成可测/可界定量" |
| **P2/P3** 组装增益 > max(single) 且存在上限 | **裸主张已死；"并集+ceiling"形态也被 `2610.03025` 占先**；**跨模型准则级测量仍活** | 下游准确率支持；准则覆盖仅一个单域证据 | 贡献必须限定为"**以专家 golden-rub 为分母、跨 LLM backbone、准则级**的并集曲线与上限"；不能主张"首个做并集上限" |
| **H2** 覆盖差异→self-preference 并解释额外方差 | **仍活**：无人把覆盖差异作为 SPF 机制 | **承压**：多个邻近证据不利于"纯内容覆盖"读法 | 必须收窄操作化：内禀覆盖、独立于展示 rubric，并控制四个对手 |
| **golden-rub** 专家准则可当真值 | 不适用 | **不可直接假设**：专家 rubric 自身有权重错误、集合级一致性仅 ~45% | 必须先做效度审计，并把标注噪声计入覆盖率估计 |

**总体门（暂定，待 R6 后落定）**：不是 PASS，也不是全面 NOVELTY-DEATH。更接近 **NOVELTY-DEATH（仅限 P1(a) 子命题）→ 按协议回退假设层、切到未测侧面重立靶**：保留 H1/H2 框架，把 P1(a) 从"贡献"降为"前提"，把 P1(b)/系统性/P2/P3/H2 重写为**测量型**主张。

---

## 1. P1(a)：新颖性已死（同构念、多源复现）

| 测量 | 覆盖/遗漏数值 | 出处记录 |
|---|---|---|
| RubricBench：5 个自动生成器 vs 专家 atomic rubric | 最高 Rubric Recall **53.8%**（CheckEval）；原文 "missing nearly half of the critical constraints"；Hallucination **>70%**（逐方法值与 26.3% 下限见 Table，md 中可直接核实的是上限与 "nearly half"） | `10.18653/v1/2026.acl-long.1439` |
| RubricRAG：zero-shot Qwen3-14B vs HealthBench/ResearchRubrics | Missed@0.2 = **56.4%**（覆盖率 43.6%），阈值敏感 | `2603.20882`（Tier-1）；另有一条 Tier-0 记录 |
| 2611.25557：M&A 文档域，单次 GPT 调用 baseline | reference recall **0.782**；候选池上限 0.876 | `2611.25557#a` |
| llm-rubrics-meta：PaperBench，4 种 scaffold × 3 backbone | 生成 rubric 的 recall 偏低、F1 0.49→0.70 | `llm-rubrics-meta-aacl2026` |
| AxisRubric：多模态轴发现（ICLR 2027 投稿） | instruction-derived "miss about **98%** of the delivery-quality axes"（Table 1 给 1.4–2.0% 覆盖率）；output-aware 仍漏 up to 32% | `kgdraAm0fG` |
| Rubrics Always Miss：6 个自动管线 on RubricBench | Miss **0.342–0.474**（覆盖率 0.526–0.658） | `EnWBxpAKPd#cov` |

**结论**：任何"我们发现 single-rub 覆盖不完整"的写法都会被判重复。可保留的 P1 是：
1. **覆盖缺口的分布结构**（per-criterion 漏检率、按准则类型的集中度）；
2. **跨模型的漏集重合**（missed-set 的 φ/Jaccard/共现是否显著高于独立零模型）；
3. **多 rubric 并集随 k 的覆盖曲线与上限**。

## 2. P1(b)/系统性：确实无人测，但已有强旁证

**直接测量缺失**：R6 之前的全部记录中，没有任何一篇计算"不同模型生成的 rubric 各自漏掉哪些准则"并比较这些集合。已核对的近似工作都停在别的层面：

- `2608.01000`：在 acceptable-set 任务上 omission 主导（植入 over-inclusion 检出比 omission 高 6–7x；生产 43,227 条 10:1），同模型 K=16 并集 recall ≤0.842；但对象是成员集合，不是 rubric 准则。
- `2608.31016`：8 种 judge 设计对"缺失事实"的 paired discrimination 仅 0.50–0.63（随机），对"增改"0.79–0.94；投票与 prompt 优化不能恢复；但 8 设计共用同一 GPT judge，无跨模型漏集统计。
- `2609.16816`：11 个生成器被利用 8–26%，失败跨厂商（DeepSeek 与 Opus 的 per-type profile 在一个环境内、32/45 环境一致）；但 DV 是利用性，不是覆盖率。
- `2603.25133#types`：Format Structure / Role Persona 对所有 judge family 都难 → "同一批侧面被漏"的旁证。
- `2510.15859#gen`：固定协议只换 rubric 生成器，下游分差 10.0–21.3，作者归因 coverage；`2510.15859#set` 的 Jaccard 0.013/0.014 是**同一生成器内部**的准则多样性，不是跨生成器重合。

**方法论类比（非命中，但可直接借用）**：Zenodo 20033048 在"多智能体失败标注"上计算 FN Jaccard——跨厂商 LLM-LLM 0.79、同厂商跨规模 0.76、同模型多采样 0.99、跨层 heuristic-vs-LLM 0.42。这正是 A 所需的统计量（重合率 + 零模型），只是对象是 trace failure labels 而非 rubric 准则。NeurIPS 2026 "Agreement without Coverage"（OpenReview PcPlRvDFiC）进一步证明"一致性不能识别覆盖率"，因此 A 必须**直接测覆盖率**，不能用 judge 间一致性作代理。

**测量形态的新颖性风险（R11 新增）**：`2610.03025` 用 Good–Turing missing mass（μ̂=f1/N）与 whisker（G·μ̂/(1−μ̂)）估计"未被任何 proposer 提出的准则"的价值上界，并报告 code/math/journalism/law ≥85%、humor/creative writing/peer review 61–85% 的 articulable 覆盖。它的分母是行为标签的可判别性（稠密模型 VAT 为上限），**不是专家 golden-rub 的准则集合**，也没有跨模型漏集重合检验；但它已经使"覆盖不完备可被量化/界定"不再是新贡献。`2604.07650` 提供条件独立性零模型：给定 prevalence conditioner 的 leave-pair-out 估计，可改造为"令 d_c 为准则 c 的 catchability（其它 k−2 个生成器包含 c 的比例），检验观测共漏是否超过 p_i(d_c)·p_j(d_c)"——这正是 P1 系统性所需的统计设计。

**判断**：P1(b)/系统性仍可做，但必须明确"我们测的是漏集重合的统计结构，而不是再报一次聚合覆盖率"。

## 3. P2/P3：裸主张已被占据，准则级测量仍空

**裸主张"组装/并集有帮助"已被三处占据**：

- `2607.01830`（MRRG）：5 个角色 prompt 的组装在 RewardBench-2/JudgeBench 上 > 最佳单角色 > 同角色重复采样（下游准确率）。
- `2611.25557#b`：GPT ∪ 多轴系统 = **0.934** recall vs 0.829 / 0.895（仅 2 任务；单模型族；准则等价判定与生成用同一个 `gpt-5.6-sol` 部署）。
- `2610.38220#merge`（Rubricon）：同模型 5 草稿并集优于"选择的单草稿"（ρ 0.364→0.402，准则数 20.6→103.2），但被精选单草稿 0.428（32.3 条）反超 → 并集有效但低效、会饱和。
- `2608.10996`（ConRub-Med）：3 个异质模型独立提准则，只保留 \|S\|=3 的交集共识；准则级临床相关性 99.3% vs 单生成器 86.8%/86.0%（+12.5/+13.2 pp）。**但保留集 ⊆ 每个生成器的候选集，集合论上不可能给出覆盖率增益**；non-redundancy 点估计为负；作者自陈"三生成器可能共享同一错误，一致同意会排除只被 1–2 个模型提出的有用准则"。→ 这是"**组装增益 ≠ 互补性**"的直接反例，也把缺口 A 的空白钉实。

**上限有可借用的定量先例（但都是 judge 票级）**：

- `2605.29800#a`：9 judges 的 Kish n_eff = **2.18**（φ̄=0.391），k=2..9 曲线 1.45→2.18，渐近上限 **1/φ̄≈2.56**；最佳单 judge 在 4/4 数据集 ≥ 整组。
- `2606.03043#ens`：集成曲线逐 k 递减因子 0.59–0.62，外推硬上限；CV R² ≤0.446。
- `2610.07109`（JudgeMoE）：judge 间误差相关 ρ≈0.7775/0.7071；对最强单体 +0.0393，但原始 10 格 CI 跨零。
- `2610.15938#variety`：展示 63% 约束即回收几乎全部收益（−0.120→+0.042 vs 满集 +0.048）。

- `2610.03025#union`（R11）：准则发现算法 bank 的并集 + ceiling；committed articulated ceiling = max(ours, ours∪ext) + Good–Turing whisker；union 的实现增益在 10/13 任务上超过 whisker，但 union 不稳定优于最佳单 bank（5 胜 8 负），且 union 轴是"发现算法"、共享同一 Qwen3-32B，结果是 bank 级 AUC、无 gold rubric。→ **"并集 + ceiling"的形态已被占先**。

**判断**：我们的 P3 贡献必须写成"**以专家 golden-rub 为分母、跨 LLM backbone、准则级**的并集曲线/上限"，并借用 Kish/φ 与 Good–Turing 的形式；不能写成"组装优于单体"或"首个做并集上限"——两者都已被占。另一个必须解释的反例：`2610.38220#merge` 说明并集增益可能被"定向增删"反超，所以问题不是"加得越多越好"，而是"边际覆盖在哪、何时饱和"。

## 4. H2：机制未被测过，但真值承压（最重要的改判）

**直接测量缺失**：没有任何工作在相同构念下把"模型生成 rubric 对 golden-rub 的覆盖/准则选择差异"作为 self-preference 的机制，并做额外方差分解。最近对手：

- `2604.06996`：固定 rubric 下的 rubric-level SPB；已拆 length / perplexity / self-recognition，残差仍在 → H2 必须解释这些之外的额外方差。
- `2611.18616`：**去掉"被展示的 rubric"后 SPF 未减弱**（ARB +1.22→+1.26；7/8 judge 仍显著），作者结论 "removing the rubric did not weaken the self-preference effect"。但：rubric 固定、主条件明确允许 ranking 忽略 rubric、两条件 91.5% 判定一致（操纵很弱）、100 vs 620 题非配对且无差值检验 → 它只反证"展示 rubric 文本是因果通道"，不反证"内禀覆盖"。
- `2611.18616#ctl`：identity reveal 仅解释约 **8%**；作者把残余归因于 style/formatting/reasoning conventions，但未测 perplexity/style。
- `2609.30048`：代码域，SPF 可被可移除表面特征完全解释（AST 归一化后 +11.8→−1.1）；"一般品味 × 自身生成习惯"的机制形态已被示范 → H2 的新颖性不能只声称这个形态，必须落在**覆盖轴**。
- `XhOtVNihIJ#dec`：四类表面通道至多解释一半残差；但 writer 效应 +0.196 ≫ argument 效应 +0.037 → 残差更像作者指纹而非内容覆盖；且 "已知解释不足" 已不是我们的新发现。
- `2603.11027`：仅共享 5 个通用维度名就把 judge 间一致性从 0.22–0.25 拉到 0.54–0.70 → **通用维度结构**是必须控制的混淆项。
- `2608.18091`（Findings EMNLP 2026）：**目前最强的 H2 对手**。原始 self–other gap 双向存在；但排除低判别 judge、控制 selection quality 与 judge severity（含 selector 随机截距）后，正效应全部消失；仅"作者标签"就足以让同一目标双向移动分数（平均 +0.43），familiarity 不是主要驱动。其 rubric 外生固定 → coverage 无方差，因此其零结果与 H2 并不矛盾，但也说明 H2 必须至少达到 `score ~ coverage + is_self + (1|judge) + (1|selector) + (1|selection_id)` 并报增量 R²。
- `2506.02592`（EMNLP 2025, 52 引）：DBG 指标用 gold judgment 扣除响应质量混淆；统一表面风格使偏差降 30–60% 但**从不归零**，作者据此称"内容也贡献"，但内容从未操作化（全文无 rubric/criteria/coverage，也无回归/R²）。它是 H2"残差"主张最干净的先验模板，但同样没有测准则覆盖。
- `bNSVlDItzb`（**仅摘要，403 未取到全文**）：摘要称 judge 在读 rubric 之前已有一个可线性解码的共享质量信号，rubric 编辑改变分数不等于测量变好。若成立，这是对 H2 前提的正面威胁；但按证据纪律**只能记为待核线索，不得用于结论**。H2 的设计应预先控制"rubric 之前的 item-quality 信号"。
- `2502.01534`（ICLR 2026, 111 引）：把 generator–judge 同源做成剂量阶梯：same-model PLS 23.6% > inheritance 19.3–22.3% > same-series 8.9% > different-series 2.8%。去掉 style/format/wording 后 PLS 17.5%→9.0/9.8/11.2% → **表面通道约解释一半，仍有 ~9pp 残差**；judge 自识别近随机（41–53%），但 BERT 作者指纹 82.4%（基线 33%）。→ H2 的额外方差必须在这条阶梯与作者指纹之外成立。
- `2508.21164`：内容固定、仅换显式模型名标签即可移动偏好（最高 50pp）→ **显式品牌先验**是 H2 必须控制的第四条通道。
- `2504.03846`（ICLR 2026 投稿）：把 SP 按真值正确性切成 LSPR（有理由的偏好）与 HSPP（自身答错时的有害偏好）；最强模型 HSPP 可达 86%。但它是**偏好事件分解，不是方差分解**（全文无 variance / R²），且真假值打平分层（D_agree）可作 H2 的匹配设计。
- `gStXkqQmNk`：judge 在 rubric 与自己先验冲突时仍有 6–24% 保持原判（调优后 3–14%）→ "展示 rubric"不是决定性的因果通道；且原 rubric 下一致性 0.959–1.000 已饱和，不能用来证明遵循。与 `2611.18616` 相互印证。
- `mrT24hQI3b`：judge 会把 rubric 明确要求忽略的证据计入判定（有效准则集 > 适用准则集）→ 这是**仪器泄漏**，不是遗漏；提示"用 verdict 反推覆盖"必须隔离已编码但被豁免的证据。

**判断**：H2 的"强版本"（展示 rubric 的覆盖差异导致 SPF）应判 **TRUTH-DOUBT / 需收窄**；"窄版本"仍可成立，但操作化必须满足：
1. coverage 是**内禀**的，独立于交付给 judge 的 rubric 文本；
2. 控制 style、perplexity、self-recognition、**作者标签/作者指纹**（`2608.18091` 显示仅标签即可双向移动分数）、通用维度结构（`2603.11027`）、selector/selection-id 随机截距（`2608.18091` 中这是让 β_S 从 +0.18 塌到 +0.003 的关键），以及 rubric 之前的 item-quality 信号（`bNSVlDItzb`，待核）；
3. 报告**额外方差**（嵌套回归 ΔR² 或等价），而不是只报相关/效应量；因变量可用 `2506.02592#dbg` 的 DBG（已扣除响应质量）；
4. 用固定响应设计（ARB 式：同一答案由自己 vs 外部 judge 评）避免答案质量混淆。

## 5. golden-rub 来源与测量协议输入

**可用真值来源**：

- **PRBench**（`10.18653/v1/2026.acl-long.1958#gt`）：1,100 任务 / 18,711 条专家准则，182 名专业人士；专家-专家在固定准则上的 κ=0.589、Macro F1=0.813；逐条接受率 93.9%（不是集合级一致性）。
- **HealthBench**（`2505.08775`）：医生撰写的 instance-specific rubric。
- **ResearchRubrics**（`2511.07685`）：长程研究任务的专家 rubric。
- **LEGIT**（`10.18653/v1/2026.acl-long.150`）：法律 issue tree，律师-律师 α=0.87（对**固定准则**的判定一致性）。
- **ClinConsensus**（`10.18653/2026.findings-emnlp.1339`）：医生校准的准则判定，pooled MF1 0.706–0.837。
- **RubricBench**：专家 atomic rubric（`10.18653/v1/2026.acl-long.1439`）。
- **FinResearchBench II**（R10 核实）：标题写 "Consensus-Derived Gold Rubrics"，但其共识是 **3 个 LLM judge 对每条准则在各报告上的判定全票一致 + 可区分性过滤**，候选准则由模型报告自动合成，人类专家只验证标签级一致（98.67%）→ 是"LLM 判定共识"，**不能当准则集级专家共识使用**。
- **Delphi360**（`10.1186/s12911-020-1071-x`）：唯一的"准则**集合**级共识"协议模板；但集合级语义一致率仅 **44.95%**（2 名编码者独立建码 + 3 人多数票）。

**必须写进协议的效度约束**：

1. 专家 rubric 自身可能错：`2604.01375#gt` 发现 48 份专家 rubric 中 10 份权重反校准；PRBench 的 "Collectively Exhaustive" 只是设计目标，从未被检验（`10.18653/v1/2026.acl-long.1958#gt`）。
2. 集合级标注噪声必须扣除：Delphi360 的 44.95% 意味着"覆盖率<1"的估计不能把标注噪声算成模型缺口。
3. 匹配协议不能由同模型兼任：`2611.25557#a` 的准则等价判定与生成用同一部署，这是可攻击的方法学弱点。
4. 覆盖必须声明加权与否：`2610.19915` 显示均匀权重在 6/6 基准上劣于重要度加权（相对 +1.64%~+5.79%），但权重从未对专家重要度校准。
5. 准则不独立：`8aJzGgbRDL#dep` 显示依赖是场景化而非普遍（42.6% 实例无可连边），"覆盖=集合并"只是一阶近似；需要在报告依赖的结构里改用图覆盖。
6. 固定 rubric ≠ 有效真值：`2608.18091#rubric` 的 4 维 rubric 未经人类标注验证，作者明确只把它当"held-constant 比较框架"、不主张准则完备性；这提示我们：固定框架可做条件比较，但不能替代经过审计的 golden-rub。

## 6. 锚点工作（方法学模板）

| 用途 | 论文 | 可借用的具体装置 |
|---|---|---|
| 覆盖率定义与诊断 | `10.18653/v1/2026.acl-long.1439` | Rubric Recall + Hallucination Rate + 下游判别三件套 |
| 覆盖率与下游解耦 | `2603.20882` | Missed@τ / Hallucinations@τ / Redundancy@τ（τ 敏感性必须报告） |
| rubric 自身质量 | `2604.01375` | RIFT 九类失败 + 因果注入 + CVR/ρ_ord/FSR |
| 准则级冗余/互补 | `2610.24971#a` | per-check Shapley：unique catch / false-fail blame |
| 聚合上限 | `2605.29800#a` | 成对 φ → Kish n_eff = k/(1+(k−1)φ̄)，渐近 1/φ̄；逐 k 曲线 |
| panel 设计 | `2608.19802` | copy/complement/specialist + 显式 stop rule + matched-K 对照 |
| 集成误差机制 | `2312.09244` | 谱系轴 vs 采样轴；预训练种子多样性 ≫ 微调种子 |
| SPB 的 DV 设计 | `2611.18616#ctl` | ARB（固定响应、自己 vs 外部 judge、位置校正、按题聚类） |
| rubric 仪器隔离 | `2605.12474` | 固定 judge panel，rubric-based vs rubric-free 对照 |
| SP 的真值分层 | `2504.03846` | LSPR / HSPP：把自偏好按真值正确性切成"有理由"与"有害"两半；真假值打平分层测残余 |
| 多生成器对照 | `2510.15859` | 固定 prompt/evaluator，只换 rubric 生成模型 |
| 集合级共识 | `10.1186/s12911-020-1071-x` | 双编码独立建码 → 语义匹配 → 多数票 → 报告集合级一致率 |
| 估计"未见准则"的规模/价值 | `2610.03025#miss` | Good–Turing μ̂=f1/N、whisker=G·μ̂/(1−μ̂)、species-accumulation 曲线、多 proposer 互捕估计 μ∪、反演 k* |
| 跨模型共漏的独立性零模型 | `2604.07650` | prevalence-conditioned 条件独立性 null（leave-pair-out 估计 conditioner）；把"准则被其它生成器包含的比例"作为 difficulty/catchability 协变量 |
| 合成语料/对照的效度门 | `2607.13707` | oracle-bearing 确定性扰动变体；聚合前 stimulus-validity gate（读 15–20 原始样本、报告退化率）；长度分层（metric 可跨长度区间变号）；producer-swap 不能替代 oracle |

## 7. 子域 mismatch / failure-mode notes（汇总）

- **D1**：最关键的错位不是"没覆盖"，而是**测的层次不同**——RubricBench/RubricRAG 测的是聚合覆盖率（单生成器 vs 单 gold），没有测漏集的重合结构，也没有把专家 rubric 自身的完备性当变量。
- **D2**："multi" 在文献里有三种互不相同的含义：同模型多次采样（GenRubric/Rubricon）、同模型多角色（MRRG）、多模型合并（RubricHub）。只有最后一种接近我们的 multi-rub，且它只报下游分数、不测准则级覆盖/重叠。
- **D3**：几乎所有生成方法优化下游 judge/preference 准确率；覆盖率最多是"动机陈述"（如 `2602.05125` 的 coverage deficiency），不是被测量的对象。
- **D4**：所有 SPB 研究都固定评价工具（pairwise 或固定 rubric），因此"覆盖差异"这个自变量被设计消掉了；H2 的构念在他们的设置里不可见。
- **D5**：所有专家一致性指标都是"给定准则后判断 met/not-met"，不是"两位专家独立写出的准则集合是否重合"；golden-rub 的**完备性**从未被当作可测量对象。

## 8. 建议的假设改写（Layer-B 结论，待用户决策）

1. **P1**：从"single-rub 覆盖不完整"改为"**遗漏的结构**：per-criterion 漏检率在跨模型间是否显著相关（φ/Jaccard vs prevalence-conditioned 独立性零模型），以及遗漏是否集中于可命名的准则类型"。**不得主张**"首个把覆盖不完备做成可测/可界定量"（`2610.03025` 已占）。
2. **P2/P3**：从"组装能提高覆盖率"改为"**并集覆盖曲线**：以专家 golden-rub 为分母，跨模型 rubric 的 union coverage 随 k 的增长曲线、边际增益位置与饱和上限，并与同模型重复采样/多角色组装对照"。**不得主张**"首个做并集上限"（`2610.03025#union` 已占）。
3. **H2**：从"覆盖差异导致 bias"改为"**内禀覆盖差异**在控制 style/perplexity/self-recognition/writer 指纹/通用维度结构后，是否仍能解释 SPF 的额外方差；若不能，明确报告并降级为竞争解释"。
4. **golden-rub**：从"专家 rubric 即真值"改为"**审计后的专家共识准则集**"，报告集合级一致率与标注噪声下界。

## 9. 尚未完成 / 未验证

- 第 1–10 轮已完成；R8/R9/R10 为连续三个 dry 轮，停止准则的饱和项已满足。R11 已完成 OpenAlex 补检：0 个 A/B/C 命中，新增 `2610.03025` 使"首个可界定覆盖不完备/首个并集上限"两条辅助主张失效（见 §0、§8）。最终裁定见 `exit-eval.md`。
- 第 10 轮的补充澄清：FinResearchBench II 的 "Consensus-Derived Gold Rubrics" 是 **3 个 LLM judge 对判定全票一致 + 可区分性过滤**，人类专家只验证标签级一致（98.67%），**不是准则集级专家共识**；VTC-Bench 的 union-over-attempts 曲线对象是"多次采样的可用产出"，不是 rubric 准则。
- OpenAlex 后端在第 4–10 轮持续故障；**R11 已恢复并完成补检**（4 篇核心论文共 237 条被引逐条筛 + 4 组新措辞），**0 个 A/B/C 直接命中**。剩余限制：S2 匿名 429，2502.01534 的 OpenAlex 169 与 S2 180 的差额未逐条核到；"空白"仍是检索通道意义，不是逻辑不存在证明。
- 3 条 Tier-0 记录（`2603.20882` 的重复、`W7127170724`、`W4416176618`）不用于结论。
- "无人测过"是**检索意义上的空白**，不是逻辑上的不存在证明；出口自评须保留这一限定。
- 尚未做：把上述改写回写 TODO.md、确定测量对象与协议、预实验设计。
