# 文献调研 · 操作协议(Phase 1)

> 本文件是**入口人类门**:用户批准它之后,执行会话才按此**自主(无 human-in-loop)**开跑调研,
> 唯一例外是触发 `SCOPE-SHIFT` 门时需上报用户(见 `GATES.md`)。
> 假设与研究问题以 `../../TODO.md` 为准(single-rub / multi-rub / golden-rub、RQ、H/P1–P3、H2)。

## 1. 这次调研要裁决什么

对以下每一项,给出明确结论 + 证据指针:

- **P1/P2/P3 的新颖性与真值**:别人是否已在**与我们相同的构念**下测过(→ 新颖性);已有证据是否**反对**它(→ 真值存疑);还是支持/未做。
- **H2 的对手定位**:现有 self-preference / 同家族 bias 的主流机制解释(风格熟悉度 / perplexity / 自我识别)各是什么、强度如何。
- **锚点工作**:≥1 篇实证类论文可作方法学模板(指标、控变量、呈现方式)。
- **golden-rub 来源**:什么数据/专家标准可当真值,别人如何比对。

## 2. 按假设拆子域(不按关键词)

| 子域 | 要回答 | 对应 |
|---|---|---|
| D1 rubric 的实证研究 | 有没有人测过"单 rubric 对真值标准的覆盖缺口" | P1 新颖性 |
| D2 multi-/ensemble/multi-perspective rubric | 多视角组装做过没、结论如何 | P2/P3 新颖性 + 锚点 |
| D3 rubric 生成方法 | 现有"锤子"有哪些(做 baseline) | 方法层 |
| D4 LLM-judge self-preference / 同家族 bias | 现有主流机制解释 | H2 对手 |
| D5 真值标准来源 & 评测协议 | 什么能当 golden-rub、如何比对 | 测量协议输入 |

**每个子域结束时必须写一条 mismatch / failure-mode note**:别人的构念/设置/操作与我们差在哪。无此 note 的子域视为未完成。

## 3. 证据纪律

- **分级**:Tier-0 仅标题/摘要 = **只用于筛选,永不作结论依据**;Tier-1 读正文核心 = 任何"别人做过/没做过/反对"的断言都必须基于它。
- **逐字锚定**:每条抽取的事实都挂 `逐字引文 + 出处(file:line 或 Lnn)`,经 `fetch_paper.sh` + Read 得到。
- **id 实查**:精确 id 来自检索 API,**绝不凭记忆**;每条标 `fulltext` vs `abstract`。
- **snippet ≠ 证据**:凡机制性/新颖性关键断言,回到**主文全文**核对(尤其当片段"恰好"支持我们想要的结论时)。
- **两条正交质量轴**:外部(venue/引用/**近因**)与内在(剥掉叙事后比 baseline 多了什么),不混为一谈;按近因加权(LLM 领域更新快)。
- **方法论文采纳前预检**:in-loop vs out-of-loop;文本反馈 vs 数值梯度;topology-role(被优化对象 vs 参照对象的角色是否与我们问题同构)。

## 4. 交付物分层(检查友好)

- **Layer A(廉价可检)**:结构化记录写入 `records.jsonl`(schema 见 `record-schema.md`)——每条带可解析链接 + 逐字引文 + 出处。检查 = 瞄一眼。
- **Layer B(不可约综合)**:findings、与 H 的关系、新颖性裁决、mismatch note——每条**引用其所依据的 Layer-A 记录 id**;检查用**抽样重读**,不要求全读。

## 5. 工具接线

- **检索 / 元数据 / 引用图**:`paper-search` MCP ——
  `search_papers`(多源统一+去重)、`search_openalex`、`search_semantic`、`search_dblp`;
  `get_referenced_papers`(它引谁)、`get_citing_papers`(谁引它)。
  **主力后端 OpenAlex(无需 key,完整)**;S2 key 申请被拒,S2 匿名端点仅作偶发补充(无 key 频繁 429,不作依赖)。
  ⚠️ MCP 工具需**会话重启**才出现(现已 user scope / 全局,cwd 无关)。
  ⚠️ **OpenAlex 限流 = 空结果(HTTP 200 但 results=0)**,不是报错。已配 `OPENALEX_EMAIL`(polite pool)缓解。
  纪律:每批检索带一个**控制查询 canary**(如裸 `"rubric"`);若 canary 也返回 0 → 判定为后端限流/瞬时故障,**退避重试(指数 backoff),其 0 结果永不计为负向证据**;canary 正常时的真·0 才是负向证据。
- **全文(arXiv)**:`../../src/fetch_paper.sh <arxiv_id>` → 落到仓库根 `papers/<id>/`,打印带 `file:line` 锚点的标题树;
  LaTeX 源读 `sec*.tex`,PDF-only 读 `paper.md`;引用一律写 `file:line`。
- **全文(非 arXiv:纯 ACL Anthology / 期刊 / 无 arXiv 版)**:走 MCP `read_openalex_paper` /
  `read_semantic_paper` / `read_acm_paper` 等 `read_*_paper` 工具取正文;`location` 记 `tool:章节/标题`
  (如 `read_acm_paper:§4.2`),逐字引文纪律与 arXiv 路径一致。无任一路径可取全文的论文**只能停在 Tier-0,不得作结论依据**。

## 6. 执行循环

1. 对每个子域 D1–D5,起 2–3 种措辞的种子查询。
2. Tier-0 筛选命中 → 选核心候选 → `fetch_paper.sh` → Tier-1 读 → 向 `records.jsonl` 追加记录(含引文+出处)。
3. 对核心论文用引用图(`get_referenced_papers`/`get_citing_papers`)**滚雪球**。
4. 每轮向 `saturation-log.md` 记一行 `新增 vs 已见`,让饱和成为可见曲线。
5. 直到满足停止准则(见 `GATES.md`),落到某个结束门。

## 7. 出口自评(检查友好,不是自我打勾)

退出时产出**可清点的事实**,不是勾选框:

- 各子域记录数;带"引文+出处"的记录占比;链接可解析率;**缺 mismatch note 的子域清单**;饱和曲线。
- 抽 k 条 Layer-B 判断做深度重检(抽样,不全读)。

据此落到 `GATES.md` 的某个门;若 PASS 则交用户决策是否进入"测量对象与协议"阶段。
