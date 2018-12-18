#ifndef BELL_HEX_UTIL_H_
#define BELL_HEX_UTIL_H_

#include <algorithm>
#include <stdexcept>
#include <iostream>
#include <sstream>

namespace bell {
  std::string hex_to_byte(const std::vector<unsigned char> input) {
    static const char* const lut = "0123456789abcdef";

    int len = input.size();
    if (len & 1) throw std::invalid_argument("odd length");
    
    std::string output;
    output.reserve(len / 2);
    for (size_t i = 0; i < len; i += 2) {
      char a = input[i];
      const char* p = std::lower_bound(lut, lut + 16, a);
      if (*p != a) throw std::invalid_argument("not a hex digit(a)");
      
      char b = input[i + 1];
      const char* q = std::lower_bound(lut, lut + 16, b);
      if (*q != b) throw std::invalid_argument("not a hex digit(b)");
      long value = ((p - lut) << 4) | (q - lut);
      output.push_back(((p - lut) << 4) | (q - lut));
    }
    return output;
  }
}

#endif // BELL_HEX_UTIL_H_




