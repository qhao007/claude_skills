# 子代理Prompt模板 - dvv-spec-gen-workflow

本目录包含工作流各阶段子代理使用的Prompt模板。

## 目录结构

```
references/
├── phase2.1_architecture_gen.md      # Phase 2.1: 架构生成
├── phase2.2_architecture_review.md   # Phase 2.2: 架构审查
├── phase3.1_interface_gen.md         # Phase 3.1: 接口生成
├── phase3.2_interface_review.md      # Phase 3.2: 接口审查
├── phase4_spec_gen.md                # Phase 4: SPEC生成
├── phase5_completeness_review.md    # Phase 5: 完整性审查
└── phase6_content_review.md         # Phase 6: 内容审查
```

## 通用说明

### 经验注入
在每个子代理执行时，应根据任务类型注入相关经验：
- 架构规划：项目CLAUDE.md、workflow文档
- 接口定义：协议文档、接口标准
- Design SPEC：SystemVerilog开发经验
- Testbench SPEC：Testbench最佳实践

### 输出格式
所有子代理应输出标准化的审查报告，包含：
- 审查结果（PASS/NEEDS_REVISION/FAIL）
- 通过项列表
- 需要修改项列表（如有）
- 建议
