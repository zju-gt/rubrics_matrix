# Layer-A 记录 schema

> 结构化数据写入同目录 `records.jsonl`(**每行一个 JSON 对象**,append-only)。
> 本文件只定义字段;判断/综合(Layer-B)写别处的散文,不混入此处。

## 字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | 精确 id(arXiv `2606.08077` / ACL Anthology / DOI),**实查,非记忆** |
| `link` | string | 可解析规范链接(Layer-A 秒验用) |
| `subdomain` | enum | `D1`\|`D2`\|`D3`\|`D4`\|`D5` |
| `tier` | enum | `fulltext`\|`abstract`(是否读过正文) |
| `venue` | string | 会议/期刊;preprint 标 `arXiv` |
| `year` | int | 发表年(近因加权用) |
| `citation_count` | int | 外部质量轴 |
| `their_construct` | string | 他们的操作化:测什么、怎么定义覆盖/一致性、用什么 ground truth、哪些模型 |
| `their_finding` | string | 他们的结论(客观转述,不加我们的解读) |
| `evidence_quote` | string | **逐字引文**,支撑 `their_finding`/`their_construct` |
| `location` | string | 引文出处:`sec3-methodology.tex:L8` 或 `paper.md:L60` |
| `relation_to_H` | enum | `supports`\|`threatens_novelty`\|`threatens_truth`\|`orthogonal` |
| `which_target` | string[] | 命中的靶子:`P1`/`P2`/`P3`/`H2`/`anchor`/`groundtruth` 的子集 |
| `mismatch_note` | string | 他们构念/设置与我们的差异(为何只是间接证据) |
| `anchor_candidate` | bool | 是否可作方法学锚点 |
| `confidence` | enum | `high`\|`med`\|`low`(该记录可信度) |

## 示例(一行)

```json
{"id":"2505.01035","link":"https://arxiv.org/abs/2505.01035","subdomain":"D1","tier":"fulltext","venue":"arXiv","year":2025,"citation_count":0,"their_construct":"AES on TOEFL11; compares full vs simplified vs no rubric across 4 LLMs; metric = scoring accuracy vs expert 3-point ratings","their_finding":"3/4 models keep similar accuracy with simplified rubric; detailed rubric not necessary for most","evidence_quote":"three out of four models maintained similar scoring accuracy with the simplified rubric compared to the detailed one","location":"paper.md:L7","relation_to_H":"threatens_truth","which_target":["P1"],"mismatch_note":"measures downstream scoring accuracy, not coverage of golden-rub criteria; single task (essay scoring), single-model rubrics only — says nothing about multi-perspective complementarity","anchor_candidate":true,"confidence":"high"}
```
