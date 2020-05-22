function a = vec_angl(n1,n2)
% acute angle between two vectors n1 and n2
% a = acosd(abs(dot(n1, n2)./(norm(n1)*norm(n2)))) % numerical issues low angle 
a = 2*atan2d(norm( n1*norm(n2) - norm(n1)*n2), norm(n1*norm(n2) + norm(n1)*n2)); % same as below
if 90-a <= 0; a = 180-a; end % obtain acute angle
end