CREATE TABLE IF NOT EXISTS "SLQAskDataModel" (
"keyid" text PRIMARY KEY,
"typeId" text, -- 所属大类
"ask" text, -- 提问
"answer" text, -- 回答
"createTime" text, -- 创建时间
"updateTime" text, -- 更新时间
"nextCircle" text, -- 进入下一轮记忆 1 当前 2 下一轮
"ext1" text,
"ext2" text
);
