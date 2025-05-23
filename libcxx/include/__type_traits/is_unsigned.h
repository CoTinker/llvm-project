//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___TYPE_TRAITS_IS_UNSIGNED_H
#define _LIBCPP___TYPE_TRAITS_IS_UNSIGNED_H

#include <__config>
#include <__type_traits/integral_constant.h>
#include <__type_traits/is_integral.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

_LIBCPP_BEGIN_NAMESPACE_STD

#if __has_builtin(__is_unsigned)

template <class _Tp>
struct _LIBCPP_NO_SPECIALIZATIONS is_unsigned : _BoolConstant<__is_unsigned(_Tp)> {};

#  if _LIBCPP_STD_VER >= 17
template <class _Tp>
_LIBCPP_NO_SPECIALIZATIONS inline constexpr bool is_unsigned_v = __is_unsigned(_Tp);
#  endif

#else // __has_builtin(__is_unsigned)

template <class _Tp, bool = is_integral<_Tp>::value>
inline constexpr bool __is_unsigned_v = false;

template <class _Tp>
inline constexpr bool __is_unsigned_v<_Tp, true> = _Tp(0) < _Tp(-1);

template <class _Tp>
struct is_unsigned : integral_constant<bool, __is_unsigned_v<_Tp>> {};

#  if _LIBCPP_STD_VER >= 17
template <class _Tp>
inline constexpr bool is_unsigned_v = __is_unsigned_v<_Tp>;
#  endif

#endif // __has_builtin(__is_unsigned)

_LIBCPP_END_NAMESPACE_STD

#endif // _LIBCPP___TYPE_TRAITS_IS_UNSIGNED_H
