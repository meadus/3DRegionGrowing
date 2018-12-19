MATLAB 2018 code.

3D region growing algorithm, returns the grown region (reg) as a logical array

img = desired image to be masked, 3D array
noGo = 3D array, same size as image, definining regions which should not be grown into
seedInd = seeding pixel in index form (use sub2ind if x y z is known)
thresh = maximum difference between the average of the region and a new pixel on the boundary to be added