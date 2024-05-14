data = File.read('input.txt')
wide = 25
tall = 6

# wide = 3
# tall = 2
# data = '123456789012'

def layers(wide, tall, data)
  layer_width = wide * tall
  layers_count = (data.length / layer_width)

  (0...layers_count).map { |layer|
    offset = layer * layer_width

    data
      .slice(offset...(offset + layer_width))
      .chars
      .map(&:to_i)
      .each_slice(wide)
      .to_a
  }
end


answer1 = layers(wide, tall, data)
  .min_by { |layer| layer.flatten.count { |it| it == 0 } }
  .then   { |layer| layer.flatten.count { |it| it == 1 } * layer.flatten.count { |it| it == 2 } }

def color_overlay(bits)
  bits.reverse.inject { |result, current_color|
    case current_color
    when 0 then 0
    when 1 then 1
    when 2 then result
    else raise "unknown color"
    end
  }
end

raise "none 1" unless color_overlay([0, 1, 2, 0]) == 0
raise "none 2" unless color_overlay([2, 1, 2, 0]) == 1
raise "none 3" unless color_overlay([2, 2, 1, 0]) == 1
raise "none 4" unless color_overlay([2, 2, 2, 0]) == 0

all_layers = layers(wide, tall, data)
current_layer = all_layers.first
current_layer.each_index do |i|
  current_layer[i].each_index do |j|
    result = color_overlay(all_layers.map { |layer| layer[i][j] })
    print result == 1 ? "▓" : " "
  end
  puts
end
