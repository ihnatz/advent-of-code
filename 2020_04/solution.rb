class Passport
  VALID_HCL_CHARS = (0..9).to_a.map(&:to_s) + ('a'..'f').to_a
  VALID_ECLS = %w(amb blu brn gry grn hzl oth)

  PROPERTIES = [
    :byr, # (Birth Year)
    :iyr, # (Issue Year)
    :eyr, # (Expiration Year)
    :hgt, # (Height)
    :hcl, # (Hair Color)
    :ecl, # (Eye Color)
    :pid, # (Passport ID)
    :cid, # (Country ID)
  ]

  def initialize(line)
    @values = line.split(" ").inject({}) do |description, pair|
      k, v = pair.split(":")
      PROPERTIES.include?(k.to_sym) ? description.merge({k.to_sym => v}) : description
    end
  end

  def valid?
    keys = (@values.keys - [:cid]).sort
    expected = (PROPERTIES - [:cid]).sort
    keys == expected
  end

  def strict_valid?
    return false unless valid?
    return [
      valid_byr?,
      valid_iyr?,
      valid_eyr?,
      valid_hgt?,
      valid_hcl?,
      valid_ecl?,
      valid_pid?,
    ].all?
  end

  private

  def valid_pid?
    value = @values[:pid]
    return false unless value.length == 9
    value.chars.all? { |char| (0..9).to_a.map(&:to_s).include?(char) }
  end

  def valid_ecl?
    value = @values[:ecl]
    VALID_ECLS.include?(value)
  end

  def valid_hcl?
    value = @values[:hcl]
    return false unless value[0] == '#'
    value.chars.drop(1).all? { |char| VALID_HCL_CHARS.include?(char) }
  end

  def valid_hgt?
    value = @values[:hgt]
    digits = value.to_i
    measure = value.sub(digits.to_s, "")
    return false unless ['cm', 'in'].include?(measure)
    return (150..193).include?(digits) if measure == 'cm'
    return (59..76).include?(digits) if measure == 'in'
  end

  def valid_eyr?
    (2020..2030).include?(@values[:eyr].to_i)
  end

  def valid_byr?
    (1920..2002).include?(@values[:byr].to_i)
  end

  def valid_iyr?
    (2010..2020).include?(@values[:iyr].to_i)
  end
end

passports =
  File
    .read("input.txt")
    .split("\n\n")
    .map { |desc| desc.gsub("\n", " ") }
    .map { |desc| Passport.new(desc) }

p [passports.count(&:valid?), passports.count(&:strict_valid?)]
