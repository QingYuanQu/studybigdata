# 数据表

<!-- begin -->

**左表 L**

| id  | L值 |
| --- | --- |
| a   | L_a |
| b   | L_b |

<!-- split -->

**右表 R**

| id  | R值 |
| --- | --- |
| b   | R_b |
| c   | R_c |

<!--end-->

## INNER JOIN

<!-- begin -->

<svg width="480" height="394" viewBox="40 0 280 230" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <clipPath id="svg-inner-clip">
          <circle cx="220" cy="118" r="75"/>
        </clipPath>
      </defs>
      <text x="180" y="22" text-anchor="middle" font-size="15" font-weight="bold" fill="#333">INNER JOIN</text>
      <text x="180" y="40" text-anchor="middle" font-size="12" fill="#666">L.id ∩ R.id = {b}</text>
      <!-- 仅交集 b 区域填充：左圆与右圆交集 -->
      <circle cx="140" cy="118" r="75" fill="#8E44AD" fill-opacity="0.55" clip-path="url(#svg-inner-clip)"/>
      <circle cx="140" cy="118" r="75" fill="none" stroke="#4A90D9" stroke-width="2"/>
      <circle cx="220" cy="118" r="75" fill="none" stroke="#E67E22" stroke-width="2"/>
      <text x="95"  y="124" font-size="16" fill="#333">a</text>
      <text x="180" y="124" font-size="18" font-weight="bold" fill="#fff" text-anchor="middle">b</text>
      <text x="265" y="124" font-size="16" fill="#333">c</text>
      <text x="100" y="212" font-size="12" fill="#4A90D9" text-anchor="middle">L = {a,b}</text>
      <text x="260" y="212" font-size="12" fill="#E67E22" text-anchor="middle">R = {b,c}</text>
    </svg>

<!-- split -->

**结果**（L ∩ R 的行）

| id  | L值 | R值 |
| --- | --- | --- |
| b   | L_b | R_b |

<!--end-->

## LEFT JOIN

<!-- begin -->

<svg width="480" height="394" viewBox="40 0 280 230" xmlns="http://www.w3.org/2000/svg">
      <text x="180" y="22" text-anchor="middle" font-size="15" font-weight="bold" fill="#333">LEFT JOIN</text>
      <text x="180" y="40" text-anchor="middle" font-size="12" fill="#666">保留 L.id = {a,b}</text>
      <circle cx="140" cy="118" r="75" fill="#4A90D9" fill-opacity="0.35"/>
      <circle cx="140" cy="118" r="75" fill="none" stroke="#4A90D9" stroke-width="2"/>
      <circle cx="220" cy="118" r="75" fill="none" stroke="#E67E22" stroke-width="2"/>
      <text x="95"  y="124" font-size="16" fill="#1a4d7a">a</text>
      <text x="180" y="124" font-size="18" font-weight="bold" fill="#1a4d7a" text-anchor="middle">b</text>
      <text x="265" y="124" font-size="16" fill="#bbb">c</text>
      <text x="100" y="212" font-size="12" fill="#4A90D9" text-anchor="middle">L = {a,b} ✓</text>
      <text x="260" y="212" font-size="12" fill="#E67E22" text-anchor="middle">R = {b,c}</text>
    </svg>

<!-- split -->

**结果**（保留 L 的全部行）

| id  | L值 | R值  |
| --- | --- | ---- |
| a   | L_a | NULL |
| b   | L_b | R_b  |

<!-- end -->

## RIGHT JOIN

<!-- begin -->

<svg width="480" height="394" viewBox="40 0 280 230" xmlns="http://www.w3.org/2000/svg">
      <text x="180" y="22" text-anchor="middle" font-size="15" font-weight="bold" fill="#333">RIGHT JOIN</text>
      <text x="180" y="40" text-anchor="middle" font-size="12" fill="#666">保留 R.id = {b,c}</text>
      <circle cx="220" cy="118" r="75" fill="#E67E22" fill-opacity="0.35"/>
      <circle cx="140" cy="118" r="75" fill="none" stroke="#4A90D9" stroke-width="2"/>
      <circle cx="220" cy="118" r="75" fill="none" stroke="#E67E22" stroke-width="2"/>
      <text x="95"  y="124" font-size="16" fill="#bbb">a</text>
      <text x="180" y="124" font-size="18" font-weight="bold" fill="#7a3d0a" text-anchor="middle">b</text>
      <text x="265" y="124" font-size="16" fill="#7a3d0a">c</text>
      <text x="100" y="212" font-size="12" fill="#4A90D9" text-anchor="middle">L = {a,b}</text>
      <text x="260" y="212" font-size="12" fill="#E67E22" text-anchor="middle">R = {b,c} ✓</text>
    </svg>

<!-- split -->

**结果**（保留 R 的全部行）

| id  | L值  | R值 |
| --- | ---- | --- |
| b   | L_b  | R_b |
| c   | NULL | R_c |

<!-- end -->

## FULL OUTER JOIN

<!-- begin -->

<svg width="480" height="394" viewBox="40 0 280 230" xmlns="http://www.w3.org/2000/svg">
      <text x="180" y="22" text-anchor="middle" font-size="15" font-weight="bold" fill="#333">FULL OUTER JOIN</text>
      <text x="180" y="40" text-anchor="middle" font-size="12" fill="#666">L.id ∪ R.id = {a,b,c}</text>
      <circle cx="140" cy="118" r="75" fill="#8E44AD" fill-opacity="0.32"/>
      <circle cx="220" cy="118" r="75" fill="#8E44AD" fill-opacity="0.32"/>
      <circle cx="140" cy="118" r="75" fill="none" stroke="#4A90D9" stroke-width="2"/>
      <circle cx="220" cy="118" r="75" fill="none" stroke="#E67E22" stroke-width="2"/>
      <text x="95"  y="124" font-size="16" fill="#3d1e5c">a</text>
      <text x="180" y="124" font-size="18" font-weight="bold" fill="#3d1e5c" text-anchor="middle">b</text>
      <text x="265" y="124" font-size="16" fill="#3d1e5c">c</text>
      <text x="100" y="212" font-size="12" fill="#4A90D9" text-anchor="middle">L = {a,b} ✓</text>
      <text x="260" y="212" font-size="12" fill="#E67E22" text-anchor="middle">R = {b,c} ✓</text>
    </svg>

<!-- split -->

**结果**（L ∪ R 的全部行）

| id  | L值  | R值  |
| --- | ---- | ---- |
| a   | L_a  | NULL |
| b   | L_b  | R_b  |
| c   | NULL | R_c  |

<!-- end -->

## SEMI JOIN

<!-- begin -->

<svg width="480" height="394" viewBox="40 0 280 230" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <clipPath id="svg-semi-clip">
          <circle cx="220" cy="118" r="75"/>
        </clipPath>
      </defs>
      <text x="180" y="22" text-anchor="middle" font-size="15" font-weight="bold" fill="#333">SEMI JOIN</text>
      <text x="180" y="40" text-anchor="middle" font-size="12" fill="#666">L 中能在 R 找到的行 = {b}（仅输出 L 的列）</text>
      <circle cx="140" cy="118" r="75" fill="#8E44AD" fill-opacity="0.55" clip-path="url(#svg-semi-clip)"/>
      <circle cx="140" cy="118" r="75" fill="none" stroke="#4A90D9" stroke-width="2"/>
      <circle cx="220" cy="118" r="75" fill="none" stroke="#E67E22" stroke-width="2" stroke-dasharray="5 4"/>
      <text x="95"  y="124" font-size="16" fill="#aaa">a</text>
      <text x="180" y="124" font-size="18" font-weight="bold" fill="#fff" text-anchor="middle">b</text>
      <text x="265" y="124" font-size="16" fill="#aaa">c</text>
      <text x="100" y="212" font-size="12" fill="#4A90D9" text-anchor="middle">L = {a,b}</text>
      <text x="260" y="212" font-size="12" fill="#bbb" text-anchor="middle">R（不输出列）</text>
    </svg>

<!-- split -->

**结果**（仅输出 L 的列，去重匹配行）

| id  | L值 |
| --- | --- |
| b   | L_b |

<!-- end -->

## ANTI JOIN

<!-- begin -->

<svg width="480" height="394" viewBox="40 0 280 230" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <mask id="svg-anti-mask">
          <rect x="40" y="0" width="280" height="230" fill="white"/>
          <circle cx="220" cy="118" r="75" fill="black"/>
        </mask>
      </defs>
      <text x="180" y="22" text-anchor="middle" font-size="15" font-weight="bold" fill="#333">ANTI JOIN</text>
      <text x="180" y="40" text-anchor="middle" font-size="12" fill="#666">L 中在 R 找不到的行 = {a}（仅输出 L 的列）</text>
      <circle cx="140" cy="118" r="75" fill="#8E44AD" fill-opacity="0.55" mask="url(#svg-anti-mask)"/>
      <circle cx="140" cy="118" r="75" fill="none" stroke="#4A90D9" stroke-width="2"/>
      <circle cx="220" cy="118" r="75" fill="none" stroke="#E67E22" stroke-width="2" stroke-dasharray="5 4"/>
      <text x="95"  y="124" font-size="16" font-weight="bold" fill="#fff">a</text>
      <text x="180" y="124" font-size="18" fill="#aaa" text-anchor="middle">b</text>
      <text x="265" y="124" font-size="16" fill="#aaa">c</text>
      <text x="100" y="212" font-size="12" fill="#4A90D9" text-anchor="middle">L = {a,b}</text>
      <text x="260" y="212" font-size="12" fill="#bbb" text-anchor="middle">R（不输出列）</text>
    </svg>

<!-- split -->

**结果**（仅输出 L 中无匹配的行，仅 L 列）

| id  | L值 |
| --- | --- |
| a   | L_a |

<!-- end -->
