env = {}
env.focus = "game"
env.press = {}

-- 一般角色狀態
env.vx_camera    = 200  -- 攝影機右移速度
env.vx_hero      = 250  -- 人物最高移動速度
env.ax_hero      = 80   -- 人物起跑加速度 (對跑酷差異不大)

env.fy_jump      = 200  -- 跳多高，向上推一次力道
env.force_fall   = 80   -- 跳起後，人物開始下墜時，讓他掉得更快 vy

-- 盜賊的跳躍能力
env.fy_superjump = 300  -- 跳多高，向上推一次速度

-- 盾兵的跳躍能力 (幾乎等於沒有)
env.fy_useless_jump = 160

-- 動畫播放速度，幾秒換下一張圖
env.sprite_interval_run = 0.07 -- 跑步，原本用 0.09

-- 關於爬坡
env.friction_hero = 0.00    -- 地板摩擦力，爬坡時有差

-- 碰到上坡時，會持續對人物向上推，看起來才像遊戲人物
env.vy_hero_uphill    = 30  -- 持續推力 vy
env.vy_hero_uphill_th = 140 -- 推力上限

-- 碰到下坡時，還是會向上推，看起來才不會墜落
env.vy_hero_downhill    = 60   -- 持續推力 vy
env.vy_hero_downhill_th = 200  -- 推力上限

-- 野狗行為, 有兩種隨機跳
env.vx_dog         = 270
                          -- 普通跳
env.vx_jump_dog    = 0    -- 向前加速 x
env.vy_jump_dog    = 400  -- 向上加速 y
env.chance_jump    = 0    -- 發生機率 (%)

-- Spike 被撞飛的行為
env.fx_spike_die = 300   -- 300 = 300 + random(0~100)
env.fy_spike_die = 400   -- 400 = 正負200

-- 月亮位置
env.dx_moon = 0
env.dy_moon =450

-- 捲軸背景1
env.bg1_dx = 3.5              -- 捲速，可以正負值
env.bg1_w  = 960*1.5            -- 圖片寬
env.bg1_h  = 640*1.5            -- 高
env.bg1_offset_y    = -600   -- 上下位置
env.useScrollableBG = true  -- 開啟與否 (他會擋住 box2d 除錯邊框)
env.bg1_alpha = 1


env.bg2_dx = 3              -- 捲速，可以正負值
env.bg2_w  = 960*1.5            -- 圖片寬
env.bg2_h  = 640*1.5           -- 高
env.bg2_offset_y    = -600
env.bg2_alpha = 1

-- 按多久，跳多高
env.jump_booster_th = 15   -- 向上推的次數上限

-- Camera 初始偏移
env.camera_offset_x = 150    -- 人物偏左
env.camera_offset_y = 140  -- 人物偏下

--
env.debug_box2d = false

