def new_head(snake, direction)
  new_head = snake.last.dup
  new_head.map!.with_index { |element, index| element + direction[index] }
end

def move(snake, direction)
  grow(snake, direction).drop(1)
end

def grow(snake, direction)
  snake + [new_head(snake, direction)]
end

def new_food(food, snake, dimensions)
  xs = (0...dimensions[:width]).to_a
  ys = (0...dimensions[:height]).to_a
  grid = xs.product(ys)
  (grid - (food + snake)).sample
end

def obstacle_ahead?(snake, direction, dimensions)
  next_step = new_head(snake, direction)
  body_ahead?(next_step, snake) or wall_ahead?(next_step, snake)
end

def body_ahead?(next_step, snake)
  snake.include?(next_step)
end

def wall_ahead?(next_step, snake)
  next_step[0] == dimensions[:width] or
    next_step[1] == dimensions[:height] or
      next_step[0] < 0 or
        next_step[1] < 0
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) or
    obstacle_ahead?(move(snake, direction), direction, dimensions)
end
