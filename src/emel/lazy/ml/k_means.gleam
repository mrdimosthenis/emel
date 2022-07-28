import emel/utils/zlist as ut_zlist
import emel/lazy/math/geometry
import gleam/pair
import gleam/set.{Set}
import gleam_zlists.{ZList} as zlist

fn point_groups(
  points: ZList(ZList(Float)),
  centroids: ZList(ZList(Float)),
) -> ZList(#(ZList(Float), ZList(ZList(Float)))) {
  points
  |> ut_zlist.group_by(fn(x) {
    x
    |> geometry.nearest_neighbor(centroids)
    |> zlist.to_list
  })
  |> zlist.map(pair.map_first(_, zlist.of_list))
}

fn eager_set(centroids: ZList(ZList(Float))) -> Set(List(Float)) {
  centroids
  |> ut_zlist.to_list_of_lists
  |> set.from_list
}

fn iterate(
  temp_clusters: ZList(#(ZList(Float), ZList(ZList(Float)))),
) -> ZList(#(ZList(Float), ZList(ZList(Float)))) {
  let #(centroids, groups) = zlist.unzip(temp_clusters)
  let centroid_eager_set = eager_set(centroids)
  let new_centroids = zlist.map(groups, geometry.centroid)
  let new_centroid_eager_set = eager_set(new_centroids)
  case centroid_eager_set == new_centroid_eager_set {
    True -> temp_clusters
    False ->
      groups
      |> zlist.concat
      |> point_groups(new_centroids)
      |> iterate
  }
}

pub fn clusters(
  points: ZList(ZList(Float)),
  k: Int,
) -> ZList(ZList(ZList(Float))) {
  let centroids =
    points
    |> ut_zlist.uniq
    |> ut_zlist.shuffle
    |> zlist.take(k)
  points
  |> point_groups(centroids)
  |> iterate
  |> zlist.map(pair.second)
}
