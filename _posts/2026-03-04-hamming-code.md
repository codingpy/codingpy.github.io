---
title: 汉明码
---

## 奇偶校验位（ Parity bit ）

偶校验位：

如果给定一组数据位中 1 的个数是奇数，补一个 bit(1) 在最右方，使得总的 1 的个数是偶数。\
如果给定一组数据位中 1 的个数是偶数，补一个 bit(0) 在最右方，使得总的 1 的个数是偶数。

奇校验位：

如果给定一组数据位中 1 的个数是奇数，补一个 bit(0) 在最右方，使得总的 1 的个数是奇数。\
如果给定一组数据位中 1 的个数是偶数，补一个 bit(1) 在最右方，使得总的 1 的个数是奇数。

错误检测：

如果传输过程中包括校验位在内的奇数个数据位发生改变，那么奇偶校验位将出错，表示传输过程有错误发生。
此时，数据必须整体丢弃并且重新传输。

```python
def parity_encode(data):
    return (data << 1) | (data.bit_count() & 1)


def parity_decode(code):
    assert code.bit_count() % 2 == 0
    return code >> 1
```

## 汉明码（ Hamming code ）

对于所有整数 $$r \geq 2$$ ，存在一个分组长度 $$n = 2^r - 1$$ 、 $$k = 2^r - r - 1$$ 编码。
因此，汉明码的码率为 $$R = k / n = 1 - r / (2^r-1)$$ 。

通用算法：

从 $$1$$ 开始标上序号，序号 $$2^0, 2^1, 2^2, 2^3, \dots$$ 的比特是校验位，覆盖其余的数据比特。
第 $$i$$ 个检验位元是第 $$2^{i-1}$$ 比特，从该比特开始，检验 $$2^{i-1}$$ 比特，跳过 $$2^{i-1}$$ 比特，以此类推。

1. 校验位 1 覆盖所有序号的二进制表示倒数第 1 比特是 1 的数据
2. 校验位 2 覆盖所有序号的二进制表示倒数第 2 比特是 1 的数据
3. 校验位 4 覆盖所有序号的二进制表示倒数第 3 比特是 1 的数据
4. 校验位 8 覆盖所有序号的二进制表示倒数第 4 比特是 1 的数据
5. ...

错误纠正：

可以检测并纠正单比特元错误，或检测双比特元错误。

要检查某一比特的错误，则需检查某一比特所包含的所有奇偶校验比特。
如果所有奇偶校验比特是正确的，就没有错误。

(7, 4) 汉明码：

![(7, 4) 汉明码的维恩图](/assets/img/hamming74.svg)

```python
def hamming_encode(data):
    # data bits
    d1 = (data >> 0) & 1
    d2 = (data >> 1) & 1
    d3 = (data >> 2) & 1
    d4 = (data >> 3) & 1

    # parity bits
    p1 = d1 ^ d2 ^ d4
    p2 = d1 ^ d3 ^ d4
    p3 = d2 ^ d3 ^ d4

    return (d4 << 6) | (d3 << 5) | (d2 << 4) | (p3 << 3) | (d1 << 2) | (p2 << 1) | p1


def sec_decode(code):
    return hamming_decode(single_error_correcting(code))


def single_error_correcting(code):
    p1 = (code >> 0) & 1
    p2 = (code >> 1) & 1
    d1 = (code >> 2) & 1
    p3 = (code >> 3) & 1
    d2 = (code >> 4) & 1
    d3 = (code >> 5) & 1
    d4 = (code >> 6) & 1

    # error syndrome
    s1 = (d1 ^ d2 ^ d4) ^ p1
    s2 = (d1 ^ d3 ^ d4) ^ p2
    s3 = (d2 ^ d3 ^ d4) ^ p3

    err_pos = (s3 << 2) | (s2 << 1) | s1
    if err_pos > 0:
        code ^= 1 << (err_pos - 1)

    return code


def hamming_decode(code):
    d1 = (code >> 2) & 1
    d2 = (code >> 4) & 1
    d3 = (code >> 5) & 1
    d4 = (code >> 6) & 1

    return (d4 << 3) | (d3 << 2) | (d2 << 1) | d1
```

(8, 4) 汉明码：通过在 (7, 4) 编码词上附加一个额外的奇偶比特。

![(8, 4) 汉明码的维恩图](/assets/img/hamming84.svg)

```python
def secded_encode(data):
    # Abbreviated from single error correction, double error detection.
    return parity_encode(hamming_encode(data))


def secded_decode(code):
    p4 = code & 1
    code >>= 1

    # If the parity bit indicates an error, single error correction (the [7,4] Hamming code)
    # will indicate the error location, with "no error" indicating the parity bit.
    if code.bit_count() % 2 != p4:
        return sec_decode(code)

    # If the parity bit is correct, then single error correction
    # will indicate the (bitwise) exclusive-or of two error locations.
    code = single_error_correcting(code)
    assert code.bit_count() % 2 == p4
    return hamming_decode(code)
```

## 相关链接

[Error detecting and error correcting codes](https://ieeexplore.ieee.org/document/6772729)
