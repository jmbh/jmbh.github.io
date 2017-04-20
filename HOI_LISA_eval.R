

source('HOI_aux.R')

# -------------------- 1) Load Data --------------------------------------------------------------------------------

dataDir <- '/Users/jmb/Dropbox/MyData/_PhD/__projects/thesis_AOAS/3_code/Simulation/HOIs/output/'

files <- list.files(dataDir)

files_G <- files[grep('_G_', files)]
files_B <- files[grep('_B_', files)]
files_GB <- files[grep('_GB_', files)]

n_G <- length(files_G)
n_B <- length(files_B)
n_GB <- length(files_GB)

l_G <- l_B <- l_GB <- list()
for(i in 1:n_G) l_G[[i]] <- readRDS(paste0(dataDir, files_G[i]))
for(i in 1:n_B) l_B[[i]] <- readRDS(paste0(dataDir, files_B[i]))
for(i in 1:n_GB) l_GB[[i]] <- readRDS(paste0(dataDir, files_GB[i]))


# -------------------- 2) Preprocess --------------------------------------------------------------------------------

# Re-arrange data so I can re-use my old preprocessing script

# ----- G -----
list_G_d1 <- vector('list', length = n_G)
list_G_d1 <- lapply(list_G_d1, function(x) vector('list', length = 8))
list_G_d2 <- list_G_d1
for(i in 1:n_G) {
  for(n in 1:8) {
  list_G_d1[[i]][[n]] <- l_G[[i]][[n]][[1]]
  list_G_d2[[i]][[n]] <- l_G[[i]][[n]][[2]]
  }
}
G_eval <- f_eval_3(list_G_d1, list_G_d2)

# ----- B -----
list_B_d1 <- vector('list', length = n_B)
list_B_d1 <- lapply(list_B_d1, function(x) vector('list', length = 8))
list_B_d2 <- list_B_d1
for(i in 1:n_B) {
  for(n in 1:8) {
    list_B_d1[[i]][[n]] <- l_B[[i]][[n]][[1]]
    list_B_d2[[i]][[n]] <- l_B[[i]][[n]][[2]]
  }
}
B_eval <- f_eval_3(list_B_d1, list_B_d2)

# ----- GB -----
list_GB_d1 <- vector('list', length = n_GB)
list_GB_d1 <- lapply(list_GB_d1, function(x) vector('list', length = 8))
list_GB_d2 <- list_GB_d1
for(i in 1:n_GB) {
  for(n in 1:8) {
    list_GB_d1[[i]][[n]] <- l_GB[[i]][[n]][[1]]
    list_GB_d2[[i]][[n]] <- l_GB[[i]][[n]][[2]]
  }
}
GB_eval <- f_eval_3(list_GB_d1, list_GB_d2)


# -------------------- 3) Make Figures --------------------------------------------------------------------------------

figDir <- '/Users/jmb/Dropbox/MyData/_PhD/__projects/thesis_AOAS/3_code/Simulation/HOIs/figures/'

pdf(paste0(figDir, 'G.pdf'), 8, 4)
f_plot_3(G_eval, '23')
dev.off()

pdf(paste0(figDir, 'B.pdf'), 8, 4)
f_plot_3(B_eval, '23')
dev.off()

pdf(paste0(figDir, 'GB.pdf'), 8, 4)
f_plot_3(GB_eval, '23')
dev.off()


# -------------------- 4) Additional Evaluations --------------------------------------------------------------------------------















