function matrix = matrix_generate(px, py)
matrix = rand(px, py);
for i = 1: px
    for j = 1: py
        if matrix(i, j) > 0.5
            matrix(i, j) = 1;
        else
            matrix(i, j) = -1;
        end
    end
end