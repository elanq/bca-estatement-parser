# frozen_string_literal: true

# Monkeypatch NilClass type
class NilClass
  def to_number
    0
  end
end

# Monkeypatch string type
class String
  def to_number
    return 0 if self == ''

    gsub(',', '').to_i
  end
end
