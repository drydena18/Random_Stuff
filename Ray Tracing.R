library(devtools)
library(usethis)
library(rayrender)
library(av)


scene1 = generate_ground(material=diffuse(checkercolor="grey20")) %>%
  add_object(sphere(y=0.2,material=glossy(color="#2b6eff",reflectance=0.05))) 
render_scene(scene1, parallel = TRUE, width = 800, height = 800, samples = 1000)

scene2 = generate_ground(material=diffuse(checkercolor = "grey20")) %>%
  add_object(sphere(y = 0.2, material = glossy(color = "#2b6eff", reflectance = 0.05))) %>%
  add_object(sphere(y = 6, z = 1, radius = 4, material = light(intensity = 8))) %>%
  add_object(sphere(z = 15, material = light(intensity = 70)))
render_scene(scene2, parallel = TRUE, width = 800, height = 800, samples = 1000, clamp_value = 10)

scene3 = generate_ground(material=diffuse(checkercolor="grey20")) %>%
  add_object(sphere(y=0.2,material=glossy(color="#2b6eff",reflectance=0.05))) %>%
  add_object(obj_model(r_obj(),z=1,y=-0.05,scale_obj=0.45,material=diffuse())) %>%
  add_object(sphere(y=10,z=1,radius=4,material=light(intensity=8))) %>%
  add_object(sphere(z=15,material=light(intensity=70)))
render_scene(scene3, parallel = TRUE, width = 800, height = 800, samples = 1000, clamp_value=10)

par(mfrow = c(2, 2)) 
render_scene(scene3, parallel = TRUE, width = 400, height = 400,
             lookfrom = c(7, 1, 7), samples = 1000, clamp_value = 10) 
render_scene(scene3, parallel = TRUE, width = 400, height = 400,
             lookfrom = c(0, 7, 7), samples = 1000, clamp_value = 10) 
render_scene(scene3, parallel = TRUE, width = 400, height = 400,
             lookfrom = c(-7, 0, -7), samples = 1000, clamp_value = 10) 
render_scene(scene3, parallel = TRUE, width = 400, height = 400,
             lookfrom = c(-7, 7, 7), samples = 1000, clamp_value = 10)
par(mfrow=c(1,1))

scene4 = sphere(y = -1001, radius = 1000, material = lambertian(color = "#ccff00")) %>%
  add_object(sphere(material = lambertian(color = "grey20")))
render_scene(scene4)

scene5 = sphere(y = -1001, radius = 1000, material = lambertian(color = "#ccff00",
                                                                checkercolor = "grey50")) %>%
  add_object(sphere(material = metal(color = "#dd4444")))
render_scene(scene5, width = 500, height = 500, samples = 500)

scene6 = sphere(y = -1001, radius = 1000, material = lambertian(color = "#ccff00", 
                                                                checkercolor = "grey50")) %>%
  add_object(sphere(material = lambertian(color = "#dd4444"))) %>%
  add_object(sphere(z = -2, material = metal())) %>%
  add_object(sphere(z = 2, material = dielectric()))
render_scene(scene6, width = 500, height = 500, samples = 500, fov = 40, lookfrom = c(12, 4, 0))

scene8 = sphere(y = -1001, radius = 1000, material = lambertian(color = "#ccff00",
                                                                checkercolor = "grey50")) %>%
  add_object(sphere(material = lambertian(color = "#dd4444"))) %>%
  add_object(sphere(z = -2, material = metal())) %>%
  add_object(sphere(z = 2, material = dielectric())) %>%
  add_object(sphere(x = -20, y = 30, radius = 20, material = light(intensity = 3)))

par(mfrow = c(1,2))

render_scene(scene8, fov = 40, width = 500, height = 500, samples = 500,
             lookfrom = c(50,10,0), parallel = TRUE)
render_scene(scene8, fov = 30, width = 500, height = 500, samples = 500,
             lookfrom = c(12,4,0), parallel = TRUE)

scene9 = generate_ground(depth = 0, spheresize = 1000, material = diffuse(color = "#000000",
                                                                          noise = 1/10,
                                                                          noisecolor = "#654321",
                                                                          noisephase = 10)) %>%
  add_object(sphere(x = -60, y = 55, radius = 40, material = light(intensity = 8)))
  sword = matrix(
    c(0,0,0,1,0,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      0,0,1,1,1,0,0,
      2,2,2,2,2,2,2,
      2,0,3,3,3,0,2,
      0,0,2,2,2,0,0,
      0,0,3,3,3,0,0,
      0,0,2,2,2,0,0),
    ncol = 7, byrow = TRUE)
metalcolor = "#be2e1b"
hilt1 = "#7bc043"
hilt2 = "#f68f1e"

for(i in 1:ncol(sword)) {
  for(j in 1:nrow(sword)) {
    if(sword[j,i] != 0) {
      if(sword[j,i] == 1) {
      colorval = metalcolor
      material = metal(color = colorval, fuzz = 0.1)
    } else if (sword[j,i] == 2) {
        colorval = hilt1
        material = lambertian(color = colorval)
    } else {
        colorval = hilt2
        material = lambertian(color = colorval)
    }
    scene9 = add_object(scene9, cube(y = 16-j, z = i-4, material = material))
  }
  }
}

par(mfrow = c(1,1))
render_scene(scene9, fov = 30, width = 500, height = 500, samples = 500,
             parallel = TRUE, lookfrom = c(-25, 25, 0), lookat = c(0,9,0))

scene10 = scene9
rlogo = matrix(
  c(1,1,1,0,
    1,0,0,1,
    1,1,1,0,
    1,0,1,0,
    1,0,0,1),
  ncol = 4, byrow = TRUE)

material = metal(color = "#be9d1b")

for(i in 1:ncol(rlogo)) {
  for(j in 1:nrow(rlogo)) {
    if(rlogo[j,i] != 0) {
      scene10 = add_object(scene10, cube(x = -0.4, y = 8-j/2, z = -1.25+i/2, width = 0.5,
                                         material = material))
    }
  }
}

render_scene(scene10, fov = 30, width = 500, height = 500, samples = 500,
             parallel = TRUE, lookfrom = c(-25, 25, 0), lookat = c(0, 9, 0))

frames = 360

camerax = -25*cos(seq(0, 360, length.out = frames+1) [-frames-1]*pi/180)
cameraz = 25*sin(seq(0, 360, length.out = frames+1) [-frames-1]*pi/180)

for(i in 1:frames) {
  render_scene(scene10, width = 500, height = 500, fov = 35,
               lookfrom = c(camerax[i], 25, cameraz[i]),
               lookat = c(0, 9, 0), samples = 1000, parallel = TRUE,
               filename = glue::glue("swordtest{i}"))
}

av::av_encode_video(glue::glue("swordtest{1:(frames-1)}.png"), framerate=60, output = "rswordfast.mp4")
file.remove(glue::glue("swordtestfast{1:(frames-1)}.png"))

av::av_capture_graphics(expr = {
  for(i in 1:frames) {
    render_scene(scene10, width=500, height=500, fov=35,
                 lookfrom = c(camerax[i], 25, cameraz[i]),
                 lookat = c(0,9,0),samples = 1000, parallel = TRUE)
  }
}, width=500,height=500, framerate = 60, output = "rsword2.mp4")
